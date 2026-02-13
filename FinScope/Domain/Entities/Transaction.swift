import Foundation

enum TransactionType: String, CaseIterable, Sendable, Codable {
    case income
    case expense
    case transfer
}

struct Transaction: Identifiable, Equatable, Sendable {
    let id: UUID
    var accountId: UUID
    var destinationAccountId: UUID?
    var type: TransactionType
    var amount: Decimal
    var originalAmount: Decimal?
    var originalCurrencyCode: String?
    var categoryId: UUID?
    var subcategoryId: UUID?
    var note: String
    var date: Date
    var isRecurring: Bool
    var recurrenceRule: RecurrenceRule?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        accountId: UUID,
        destinationAccountId: UUID? = nil,
        type: TransactionType,
        amount: Decimal,
        originalAmount: Decimal? = nil,
        originalCurrencyCode: String? = nil,
        categoryId: UUID? = nil,
        subcategoryId: UUID? = nil,
        note: String = "",
        date: Date = Date(),
        isRecurring: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.accountId = accountId
        self.destinationAccountId = destinationAccountId
        self.type = type
        self.amount = amount
        self.originalAmount = originalAmount
        self.originalCurrencyCode = originalCurrencyCode
        self.categoryId = categoryId
        self.subcategoryId = subcategoryId
        self.note = note
        self.date = date
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
