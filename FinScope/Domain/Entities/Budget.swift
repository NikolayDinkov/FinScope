import Foundation

struct Budget: Identifiable, Equatable, Sendable {
    let id: UUID
    var categoryId: UUID
    var amount: Decimal
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        categoryId: UUID,
        amount: Decimal,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.categoryId = categoryId
        self.amount = amount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
