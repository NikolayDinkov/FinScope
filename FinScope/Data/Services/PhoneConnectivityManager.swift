import Foundation
import Combine

#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

final class PhoneConnectivityManager: NSObject, @unchecked Sendable {
    static let shared = PhoneConnectivityManager()

    private var marketService: MarketSimulatorServiceProtocol?
    private var cancellables = Set<AnyCancellable>()
    private let lock = NSLock()
    private var lastSendTime: Date = .distantPast

    private override init() {
        super.init()
    }

    func activate(marketService: MarketSimulatorServiceProtocol) {
        self.marketService = marketService

        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        #endif

        marketService.priceUpdates
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { [weak self] update in
                self?.handlePriceUpdate(update)
            }
            .store(in: &cancellables)
    }

    private func handlePriceUpdate(_ update: MarketPriceUpdate) {
        lock.lock()
        let now = Date()
        let elapsed = now.timeIntervalSince(lastSendTime)
        guard elapsed >= 3.0 else {
            lock.unlock()
            return
        }
        lastSendTime = now
        lock.unlock()

        sendPriceUpdate(update)
    }

    private func sendPriceUpdate(_ update: MarketPriceUpdate) {
        #if canImport(WatchConnectivity)
        let codable = CodablePriceUpdate(from: update)
        guard let data = try? JSONEncoder().encode(codable) else { return }

        if WCSession.default.isReachable {
            let message: [String: Any] = [
                ConnectivityMessageKey.priceUpdate.rawValue: data
            ]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send price update to Watch: \(error)")
            }
        }

        // Always update application context so Watch gets latest prices when it wakes
        let context: [String: Any] = [
            ConnectivityMessageKey.priceUpdate.rawValue: data
        ]
        try? WCSession.default.updateApplicationContext(context)
        #endif
    }

    private func sendFullPriceSnapshot() {
        guard let marketService else { return }
        let prices = marketService.currentPrices()
        let assets = marketService.allAssets()

        var changes: [String: Decimal] = [:]
        for asset in assets {
            if let price = prices[asset.ticker], asset.basePrice != 0 {
                changes[asset.ticker] = ((price - asset.basePrice) / asset.basePrice * 100).rounded(scale: 2)
            }
        }

        let update = MarketPriceUpdate(prices: prices, changes: changes, timestamp: Date())
        sendPriceUpdate(update)
    }
}

#if canImport(WatchConnectivity)
extension PhoneConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("WCSession activation failed: \(error)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            sendFullPriceSnapshot()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if message[ConnectivityMessageKey.requestPrices.rawValue] != nil {
            sendFullPriceSnapshot()
        }

        if message[ConnectivityMessageKey.tradeExecuted.rawValue] != nil {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .dataDidChange, object: nil)
            }
        }
    }
}
#endif
