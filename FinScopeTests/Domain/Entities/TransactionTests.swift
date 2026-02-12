import Testing
import Foundation
@testable import FinScope

struct TransactionTests {
    @Test func testTransactionCreationWithDefaults() {
        let accountId = UUID()
        let categoryId = UUID()
        let transaction = FinScope.Transaction(
            accountId: accountId,
            type: .expense,
            amount: 50.00,
            categoryId: categoryId
        )
        #expect(transaction.accountId == accountId)
        #expect(transaction.type == .expense)
        #expect(transaction.amount == 50.00)
        #expect(transaction.categoryId == categoryId)
        #expect(transaction.note == "")
        #expect(transaction.isRecurring == false)
        #expect(transaction.recurrenceRule == nil)
    }

    @Test func testTransactionWithRecurrence() {
        let rule = RecurrenceRule(frequency: .monthly)
        let transaction = FinScope.Transaction(
            accountId: UUID(),
            type: .expense,
            amount: 100,
            categoryId: UUID(),
            isRecurring: true,
            recurrenceRule: rule
        )
        #expect(transaction.isRecurring == true)
        #expect(transaction.recurrenceRule?.frequency == .monthly)
    }

    @Test func testTransactionTypeAllCases() {
        #expect(TransactionType.allCases.count == 3)
    }

    @Test func testRecurrenceRuleCodable() throws {
        let rule = RecurrenceRule(frequency: .weekly, startDate: Date())
        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(RecurrenceRule.self, from: data)
        #expect(decoded.frequency == .weekly)
    }
}
