import Foundation

struct Account: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var type: AccountType
    var currency: String
    let createdAt: Date
    var userId: UUID

    init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        currency: String = "BGN",
        createdAt: Date = Date(),
        userId: UUID
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.currency = currency
        self.createdAt = createdAt
        self.userId = userId
    }
}

enum AccountType: String, CaseIterable, Sendable, Codable {
    case cash
    case bank
    case investment
}
