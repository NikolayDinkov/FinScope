import Foundation

enum AccountType: String, CaseIterable, Sendable, Codable {
    case cash
    case bank
    case investment
}

struct Account: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var type: AccountType
    var currencyCode: String
    var balance: Decimal
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        currencyCode: String = "USD",
        balance: Decimal = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.currencyCode = currencyCode
        self.balance = balance
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
