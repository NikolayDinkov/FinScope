import Foundation
import Combine

final class MarketSimulatorService: MarketSimulatorServiceProtocol, @unchecked Sendable {
    private let assets: [MockAsset]
    private let assetsByTicker: [String: MockAsset]
    private var currentPricesDict: [String: Decimal]
    private var priceHistoryBuffer: [String: [PriceTick]]
    private let lock = NSLock()
    private var timer: Timer?
    private let subject = PassthroughSubject<MarketPriceUpdate, Never>()
    private static let maxHistoryPerAsset = 60

    var priceUpdates: AnyPublisher<MarketPriceUpdate, Never> {
        subject.eraseToAnyPublisher()
    }

    init() {
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
        DispatchQueue.main.async { [weak self] in
            guard let self, self.timer == nil else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                self?.tick()
            }
        }
    }

    func stop() {
        DispatchQueue.main.async { [weak self] in
            self?.timer?.invalidate()
            self?.timer = nil
        }
    }

    private func tick() {
        lock.lock()
        let now = Date()
        var changes: [String: Decimal] = [:]

        // Each tick, randomly pick ~15% of assets to update so prices stagger
        let batch = assets.filter { _ in Double.random(in: 0...1) < 0.15 }

        for asset in batch {
            let ticker = asset.ticker
            guard let oldPrice = currentPricesDict[ticker] else { continue }

            let volatility: Double
            switch asset.type {
            case .stock: volatility = 0.02
            case .bond: volatility = 0.001
            case .etf: volatility = 0.01
            }

            let randomFactor = Double.random(in: -1.0...1.0)
            let basePriceDouble = NSDecimalNumber(decimal: asset.basePrice).doubleValue
            let currentDouble = NSDecimalNumber(decimal: oldPrice).doubleValue
            let drift = (basePriceDouble - currentDouble) / basePriceDouble * 0.01
            let change = drift + volatility * randomFactor
            let newDouble = max(0.50, currentDouble * (1.0 + change))
            let newPrice = Decimal(newDouble).rounded(scale: 2)

            currentPricesDict[ticker] = newPrice

            let priceChange: Decimal
            if asset.basePrice != 0 {
                priceChange = ((newPrice - asset.basePrice) / asset.basePrice * 100).rounded(scale: 2)
            } else {
                priceChange = 0
            }
            changes[ticker] = priceChange

            let priceTick = PriceTick(ticker: ticker, price: newPrice, timestamp: now)
            var history = priceHistoryBuffer[ticker] ?? []
            history.append(priceTick)
            if history.count > Self.maxHistoryPerAsset {
                history.removeFirst(history.count - Self.maxHistoryPerAsset)
            }
            priceHistoryBuffer[ticker] = history
        }

        let prices = currentPricesDict
        lock.unlock()

        guard !changes.isEmpty else { return }

        let update = MarketPriceUpdate(prices: prices, changes: changes, timestamp: now)
        DispatchQueue.main.async { [weak self] in
            self?.subject.send(update)
        }
    }
}
