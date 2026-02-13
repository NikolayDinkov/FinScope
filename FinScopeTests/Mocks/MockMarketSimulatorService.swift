import Foundation
import Combine
@testable import FinScope

final class MockMarketSimulatorService: MarketSimulatorServiceProtocol, @unchecked Sendable {
    var assets: [MockAsset] = []
    var prices: [String: Decimal] = [:]
    var history: [String: [PriceTick]] = [:]
    private let subject = PassthroughSubject<MarketPriceUpdate, Never>()

    var priceUpdates: AnyPublisher<MarketPriceUpdate, Never> {
        subject.eraseToAnyPublisher()
    }

    func allAssets() -> [MockAsset] {
        assets
    }

    func currentPrice(for ticker: String) -> Decimal? {
        prices[ticker]
    }

    func currentPrices() -> [String: Decimal] {
        prices
    }

    func priceHistory(for ticker: String, limit: Int) -> [PriceTick] {
        let ticks = history[ticker] ?? []
        if limit >= ticks.count { return ticks }
        return Array(ticks.suffix(limit))
    }

    func start() {}
    func stop() {}
}
