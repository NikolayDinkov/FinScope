import Foundation
import WatchConnectivity
import Combine

final class WatchConnectivityManager: NSObject, WCSessionDelegate, @unchecked Sendable {
    static let shared = WatchConnectivityManager()

    private let priceSubject = PassthroughSubject<MarketPriceUpdate, Never>()
    var priceUpdates: AnyPublisher<MarketPriceUpdate, Never> {
        priceSubject.eraseToAnyPublisher()
    }

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func requestPriceSnapshot() {
        guard WCSession.default.isReachable else { return }
        let message: [String: Any] = [
            ConnectivityMessageKey.requestPrices.rawValue: true
        ]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to request prices from iPhone: \(error)")
        }
    }

    func notifyTradeExecuted() {
        guard WCSession.default.isReachable else { return }
        let message: [String: Any] = [
            ConnectivityMessageKey.tradeExecuted.rawValue: true
        ]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to notify trade to iPhone: \(error)")
        }
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("Watch WCSession activation failed: \(error)")
        } else {
            // Read cached application context for latest prices
            processApplicationContext(session.receivedApplicationContext)
            requestPriceSnapshot()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        processPriceData(from: message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        processApplicationContext(applicationContext)
    }

    // MARK: - Private

    private func processPriceData(from message: [String: Any]) {
        if let data = message[ConnectivityMessageKey.priceUpdate.rawValue] as? Data {
            guard let codable = try? JSONDecoder().decode(CodablePriceUpdate.self, from: data) else { return }
            let update = codable.toMarketPriceUpdate()
            DispatchQueue.main.async { [weak self] in
                self?.priceSubject.send(update)
            }
        }
    }

    private func processApplicationContext(_ context: [String: Any]) {
        guard !context.isEmpty else { return }
        processPriceData(from: context)
    }
}
