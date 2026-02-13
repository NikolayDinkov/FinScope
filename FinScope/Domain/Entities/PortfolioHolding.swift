import Foundation

struct PortfolioHolding: Identifiable, Equatable, Sendable {
    let id: UUID
    var assetTicker: String
    var quantity: Decimal
    var averageCostBasis: Decimal
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        assetTicker: String,
        quantity: Decimal,
        averageCostBasis: Decimal,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.assetTicker = assetTicker
        self.quantity = quantity
        self.averageCostBasis = averageCostBasis
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
