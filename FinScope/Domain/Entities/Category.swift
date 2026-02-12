import Foundation

struct Category: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isDefault: Bool
    var transactionType: TransactionType
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        isDefault: Bool = false,
        transactionType: TransactionType,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.transactionType = transactionType
        self.createdAt = createdAt
    }
}
