import Foundation

struct Transaction: Identifiable, Hashable, Sendable {
    let id: UUID
    var amount: Decimal
    var originalAmount: Decimal?
    var originalCurrency: String?
    var date: Date
    var note: String?
    var isRecurring: Bool
    var recurringInterval: RecurringInterval?
    var type: TransactionType
    let createdAt: Date
    var accountId: UUID
    var categoryId: UUID?

    init(
        id: UUID = UUID(),
        amount: Decimal,
        originalAmount: Decimal? = nil,
        originalCurrency: String? = nil,
        date: Date = Date(),
        note: String? = nil,
        isRecurring: Bool = false,
        recurringInterval: RecurringInterval? = nil,
        type: TransactionType,
        createdAt: Date = Date(),
        accountId: UUID,
        categoryId: UUID? = nil
    ) {
        self.id = id
        self.amount = amount
        self.originalAmount = originalAmount
        self.originalCurrency = originalCurrency
        self.date = date
        self.note = note
        self.isRecurring = isRecurring
        self.recurringInterval = recurringInterval
        self.type = type
        self.createdAt = createdAt
        self.accountId = accountId
        self.categoryId = categoryId
    }
}

enum TransactionType: String, CaseIterable, Sendable, Codable {
    case income
    case expense
}

enum RecurringInterval: String, CaseIterable, Sendable, Codable {
    case daily
    case weekly
    case monthly
    case yearly
}
