import Foundation

struct PriceTick: Identifiable, Equatable, Sendable {
    let id: UUID
    let ticker: String
    let price: Decimal
    let timestamp: Date

    init(
        id: UUID = UUID(),
        ticker: String,
        price: Decimal,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.ticker = ticker
        self.price = price
        self.timestamp = timestamp
    }
}
