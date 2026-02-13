import Foundation
import Combine

struct MarketPriceUpdate: Sendable {
    let prices: [String: Decimal]
    let changes: [String: Decimal]
    let timestamp: Date
}

protocol MarketSimulatorServiceProtocol: Sendable {
    func allAssets() -> [MockAsset]
    func currentPrice(for ticker: String) -> Decimal?
    func currentPrices() -> [String: Decimal]
    func priceHistory(for ticker: String, limit: Int) -> [PriceTick]
    func start()
    func stop()
    var priceUpdates: AnyPublisher<MarketPriceUpdate, Never> { get }
}
