import Testing
import Foundation
import CoreData
@testable import FinScope

struct AccountMapperTests {
    private func makeInMemoryContext() -> NSManagedObjectContext {
        let stack = CoreDataStack(inMemory: true)
        return stack.viewContext
    }

    @Test func testMapToManagedObjectAndBack() {
        let context = makeInMemoryContext()
        let original = Account(
            name: "Test Account",
            type: .bank,
            currencyCode: "EUR",
            balance: 500.25
        )

        let mo = AccountMapper.toManagedObject(original, context: context)
        let mapped = AccountMapper.toDomain(mo)

        #expect(mapped.id == original.id)
        #expect(mapped.name == "Test Account")
        #expect(mapped.type == .bank)
        #expect(mapped.currencyCode == "EUR")
        #expect(mapped.balance == 500.25)
    }

    @Test func testUpdateManagedObject() {
        let context = makeInMemoryContext()
        let original = Account(name: "Old Name", type: .cash, balance: 100)
        let mo = AccountMapper.toManagedObject(original, context: context)

        var updated = original
        updated.name = "New Name"
        updated.balance = 200
        AccountMapper.update(mo, from: updated)

        #expect(mo.name == "New Name")
        #expect((mo.balance as? Decimal) == 200)
    }
}
