import Testing
import Foundation
@testable import FinScope

struct AccountTests {
    @Test func testAccountCreationWithDefaults() {
        let account = Account(name: "Test Account", type: .bank)
        #expect(account.name == "Test Account")
        #expect(account.type == .bank)
        #expect(account.currencyCode == "USD")
        #expect(account.balance == 0)
    }

    @Test func testAccountCreationWithCustomValues() {
        let account = Account(
            name: "Savings",
            type: .investment,
            currencyCode: "EUR",
            balance: 1000.50
        )
        #expect(account.name == "Savings")
        #expect(account.type == .investment)
        #expect(account.currencyCode == "EUR")
        #expect(account.balance == 1000.50)
    }

    @Test func testAccountEquality() {
        let id = UUID()
        let date = Date()
        let a = Account(id: id, name: "A", type: .cash, createdAt: date, updatedAt: date)
        let b = Account(id: id, name: "A", type: .cash, createdAt: date, updatedAt: date)
        #expect(a == b)
    }

    @Test func testAccountTypeAllCases() {
        #expect(AccountType.allCases.count == 3)
        #expect(AccountType.allCases.contains(.cash))
        #expect(AccountType.allCases.contains(.bank))
        #expect(AccountType.allCases.contains(.investment))
    }
}
