import Foundation

enum TradeAction: String, CaseIterable, Sendable, Codable {
    case buy
    case sell
}

struct Trade: Identifiable, Equatable, Sendable {
    let id: UUID
    let assetTicker: String
    let action: TradeAction
    let quantity: Decimal
    let pricePerUnit: Decimal
    let totalAmount: Decimal
    let date: Date
    let createdAt: Date

    init(
        id: UUID = UUID(),
        assetTicker: String,
        action: TradeAction,
        quantity: Decimal,
        pricePerUnit: Decimal,
        date: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.assetTicker = assetTicker
        self.action = action
        self.quantity = quantity
        self.pricePerUnit = pricePerUnit
        self.totalAmount = quantity * pricePerUnit
        self.date = date
        self.createdAt = createdAt
    }
}
