import Foundation
import Combine

final class WatchMarketService: MarketSimulatorServiceProtocol, @unchecked Sendable {
    private let assets: [MockAsset]
    private let assetsByTicker: [String: MockAsset]
    private var currentPricesDict: [String: Decimal]
    private var priceHistoryBuffer: [String: [PriceTick]]
    private let lock = NSLock()
    private let subject = PassthroughSubject<MarketPriceUpdate, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let connectivityManager: WatchConnectivityManager
    private static let maxHistoryPerAsset = 30

    var priceUpdates: AnyPublisher<MarketPriceUpdate, Never> {
        subject.eraseToAnyPublisher()
    }

    init(connectivityManager: WatchConnectivityManager = .shared) {
        let catalog = MockAssetCatalog.generate()
        self.assets = catalog
        var byTicker: [String: MockAsset] = [:]
        var prices: [String: Decimal] = [:]
        var history: [String: [PriceTick]] = [:]
        for asset in catalog {
            byTicker[asset.ticker] = asset
            prices[asset.ticker] = asset.basePrice
            history[asset.ticker] = []
        }
        self.assetsByTicker = byTicker
        self.currentPricesDict = prices
        self.priceHistoryBuffer = history
        self.connectivityManager = connectivityManager

        connectivityManager.priceUpdates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.handlePriceUpdate(update)
            }
            .store(in: &cancellables)
    }

    func allAssets() -> [MockAsset] {
        assets
    }

    func currentPrice(for ticker: String) -> Decimal? {
        lock.lock()
        defer { lock.unlock() }
        return currentPricesDict[ticker]
    }

    func currentPrices() -> [String: Decimal] {
        lock.lock()
        defer { lock.unlock() }
        return currentPricesDict
    }

    func priceHistory(for ticker: String, limit: Int) -> [PriceTick] {
        lock.lock()
        defer { lock.unlock() }
        guard let history = priceHistoryBuffer[ticker] else { return [] }
        if limit >= history.count { return history }
        return Array(history.suffix(limit))
    }

    func start() {
        connectivityManager.requestPriceSnapshot()
    }

    func stop() {
        // No-op on Watch — prices come from iPhone
    }

    private func handlePriceUpdate(_ update: MarketPriceUpdate) {
        lock.lock()
        let now = update.timestamp

        for (ticker, price) in update.prices {
            currentPricesDict[ticker] = price
        }

        for ticker in update.changes.keys {
            guard let price = update.prices[ticker] else { continue }
            let tick = PriceTick(ticker: ticker, price: price, timestamp: now)
            var history = priceHistoryBuffer[ticker] ?? []
            history.append(tick)
            if history.count > Self.maxHistoryPerAsset {
                history.removeFirst(history.count - Self.maxHistoryPerAsset)
            }
            priceHistoryBuffer[ticker] = history
        }

        lock.unlock()

        subject.send(update)
    }
}
