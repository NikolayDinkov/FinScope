import Testing
import Foundation
import CoreData
@testable import FinScope

struct TransactionMapperTests {
    private func makeInMemoryContext() -> NSManagedObjectContext {
        let stack = CoreDataStack(inMemory: true)
        return stack.viewContext
    }

    @Test func testMapToManagedObjectAndBack() {
        let context = makeInMemoryContext()
        let accountMO = AccountMO(context: context)
        accountMO.id = UUID()

        let categoryMO = CategoryMO(context: context)
        categoryMO.id = UUID()

        let original = FinScope.Transaction(
            accountId: accountMO.id!,
            type: .expense,
            amount: 42.50,
            categoryId: categoryMO.id!,
            note: "Test note",
            date: Date()
        )

        let mo = TransactionMapper.toManagedObject(original, context: context)
        mo.account = accountMO
        mo.category = categoryMO

        let mapped = TransactionMapper.toDomain(mo)

        #expect(mapped.id == original.id)
        #expect(mapped.type == .expense)
        #expect(mapped.amount == 42.50)
        #expect(mapped.note == "Test note")
    }

    @Test func testMapDestinationAccount() {
        let context = makeInMemoryContext()
        let accountMO = AccountMO(context: context)
        accountMO.id = UUID()

        let destAccountMO = AccountMO(context: context)
        destAccountMO.id = UUID()

        let categoryMO = CategoryMO(context: context)
        categoryMO.id = UUID()

        let original = FinScope.Transaction(
            accountId: accountMO.id!,
            destinationAccountId: destAccountMO.id!,
            type: .transfer,
            amount: 100,
            categoryId: categoryMO.id!
        )

        let mo = TransactionMapper.toManagedObject(original, context: context)
        mo.account = accountMO
        mo.category = categoryMO
        mo.destinationAccount = destAccountMO

        let mapped = TransactionMapper.toDomain(mo)

        #expect(mapped.destinationAccountId == destAccountMO.id)
        #expect(mapped.type == .transfer)
    }

    @Test func testMapWithNoDestinationAccount() {
        let context = makeInMemoryContext()
        let accountMO = AccountMO(context: context)
        accountMO.id = UUID()

        let categoryMO = CategoryMO(context: context)
        categoryMO.id = UUID()

        let original = FinScope.Transaction(
            accountId: accountMO.id!,
            type: .expense,
            amount: 50,
            categoryId: categoryMO.id!
        )

        let mo = TransactionMapper.toManagedObject(original, context: context)
        mo.account = accountMO
        mo.category = categoryMO

        let mapped = TransactionMapper.toDomain(mo)

        #expect(mapped.destinationAccountId == nil)
    }

    @Test func testRecurrenceRuleRoundTrip() {
        let context = makeInMemoryContext()
        let accountMO = AccountMO(context: context)
        accountMO.id = UUID()

        let categoryMO = CategoryMO(context: context)
        categoryMO.id = UUID()

        let rule = RecurrenceRule(frequency: .monthly, startDate: Date())
        let original = FinScope.Transaction(
            accountId: accountMO.id!,
            type: .expense,
            amount: 100,
            categoryId: categoryMO.id!,
            isRecurring: true,
            recurrenceRule: rule
        )

        let mo = TransactionMapper.toManagedObject(original, context: context)
        mo.account = accountMO
        mo.category = categoryMO

        let mapped = TransactionMapper.toDomain(mo)

        #expect(mapped.isRecurring == true)
        #expect(mapped.recurrenceRule?.frequency == .monthly)
    }
}
