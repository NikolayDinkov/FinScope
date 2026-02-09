import Testing
import Combine
@testable import FinScope

@Suite("BudgetService Tests")
struct BudgetServiceTests {

    @Test("Evaluate budget with no rules returns correct total")
    func evaluateNoRules() {
        let budgetRepo = MockBudgetRepository()
        let txRepo = MockTransactionRepository()
        let service = BudgetService(budgetRepository: budgetRepo, transactionRepository: txRepo)

        let budget = Budget(
            name: "Test",
            period: .monthly,
            totalLimit: 1000,
            userId: UUID()
        )

        let transactions = [
            Transaction(amount: 300, type: .expense, accountId: UUID()),
            Transaction(amount: 200, type: .expense, accountId: UUID()),
            Transaction(amount: 1500, type: .income, accountId: UUID()),
        ]

        let status = service.evaluate(budget: budget, transactions: transactions)

        #expect(status.totalSpending == 500)
        #expect(!status.isOverBudget)
    }

    @Test("Evaluate budget detects over-budget")
    func evaluateOverBudget() {
        let budgetRepo = MockBudgetRepository()
        let txRepo = MockTransactionRepository()
        let service = BudgetService(budgetRepository: budgetRepo, transactionRepository: txRepo)

        let budget = Budget(
            name: "Tight Budget",
            period: .monthly,
            totalLimit: 200,
            userId: UUID()
        )

        let transactions = [
            Transaction(amount: 150, type: .expense, accountId: UUID()),
            Transaction(amount: 100, type: .expense, accountId: UUID()),
        ]

        let status = service.evaluate(budget: budget, transactions: transactions)

        #expect(status.totalSpending == 250)
        #expect(status.isOverBudget)
    }

    @Test("Budget alert fired when category rule exceeded")
    func alertOnRuleExceeded() {
        let budgetRepo = MockBudgetRepository()
        let txRepo = MockTransactionRepository()
        let service = BudgetService(budgetRepository: budgetRepo, transactionRepository: txRepo)

        let categoryId = UUID()
        let budgetId = UUID()
        let rule = BudgetRule(
            ruleType: .fixedLimit,
            limitAmount: 100,
            budgetId: budgetId,
            categoryId: categoryId
        )

        let budget = Budget(
            id: budgetId,
            name: "Test",
            period: .monthly,
            userId: UUID(),
            rules: [rule]
        )

        let transactions = [
            Transaction(amount: 150, type: .expense, accountId: UUID(), categoryId: categoryId)
        ]

        var receivedAlert: BudgetAlert?
        let cancellable = service.alertPublisher.sink { alert in
            receivedAlert = alert
        }

        let status = service.evaluate(budget: budget, transactions: transactions)

        #expect(status.isOverBudget)
        #expect(status.ruleStatuses.first?.isExceeded == true)
        #expect(receivedAlert != nil)
        #expect(receivedAlert?.currentSpending == 150)
        #expect(receivedAlert?.limit == 100)

        _ = cancellable
    }

    @Test("Percentage-based rule calculates limit from income")
    func percentageRule() {
        let budgetRepo = MockBudgetRepository()
        let txRepo = MockTransactionRepository()
        let service = BudgetService(budgetRepository: budgetRepo, transactionRepository: txRepo)

        let categoryId = UUID()
        let budgetId = UUID()
        let rule = BudgetRule(
            ruleType: .percentageOfIncome,
            percentage: Decimal(string: "0.30")!,
            budgetId: budgetId,
            categoryId: categoryId
        )

        let budget = Budget(
            id: budgetId,
            name: "Test",
            period: .monthly,
            userId: UUID(),
            rules: [rule]
        )

        let transactions: [Transaction] = [
            Transaction(amount: 5000, type: .income, accountId: UUID()),
            Transaction(amount: 1600, type: .expense, accountId: UUID(), categoryId: categoryId),
        ]

        let status = service.evaluate(budget: budget, transactions: transactions)

        // 30% of 5000 = 1500, spending is 1600
        #expect(status.ruleStatuses.first?.limit == 1500)
        #expect(status.ruleStatuses.first?.isExceeded == true)
    }
}
