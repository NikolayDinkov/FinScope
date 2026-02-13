import Testing
import Foundation
@testable import FinScope

@MainActor
struct DashboardViewModelTests {

    // MARK: - Helpers

    private func makeSUT(
        accounts: [Account] = [],
        transactions: [FinScope.Transaction] = [],
        budgets: [Budget] = [],
        categories: [FinScope.Category] = [],
        forecasts: [MonthlyForecast] = [],
        shouldThrow: Bool = false
    ) -> DashboardViewModel {
        let accountRepo = MockAccountRepository()
        accountRepo.accounts = accounts
        accountRepo.shouldThrow = shouldThrow

        let txRepo = MockTransactionRepository()
        txRepo.transactions = transactions
        txRepo.shouldThrow = shouldThrow

        let budgetRepo = MockBudgetRepository()
        budgetRepo.budgets = budgets
        budgetRepo.shouldThrow = shouldThrow

        let categoryRepo = MockCategoryRepository()
        categoryRepo.categories = categories
        categoryRepo.shouldThrow = shouldThrow

        let forecastService = MockForecastService()
        forecastService.result = forecasts
        forecastService.shouldThrow = shouldThrow

        return DashboardViewModel(
            fetchAccountsUseCase: FetchAccountsUseCase(repository: accountRepo),
            fetchTransactionsUseCase: FetchTransactionsUseCase(repository: txRepo),
            fetchBudgetsUseCase: FetchBudgetsUseCase(repository: budgetRepo),
            fetchCategoriesUseCase: FetchCategoriesUseCase(repository: categoryRepo),
            fetchCategorySpendingUseCase: FetchCategorySpendingUseCase(transactionRepository: txRepo),
            generateForecastUseCase: GenerateForecastUseCase(
                accountRepository: accountRepo,
                transactionRepository: txRepo,
                forecastService: forecastService
            )
        )
    }

    // MARK: - Balance Tests

    @Test func testTotalBalanceSumsAllAccounts() async throws {
        let accounts = [
            Account(name: "Cash", type: .cash, balance: 500),
            Account(name: "Bank", type: .bank, balance: 3000),
            Account(name: "Invest", type: .investment, balance: 1500)
        ]
        let vm = makeSUT(accounts: accounts)
        await vm.load()

        #expect(vm.totalBalance == 5000)
    }

    @Test func testPreviewAccountsLimitedToFour() async throws {
        let accounts = (0..<6).map {
            Account(name: "Account \($0)", type: .bank, balance: Decimal($0 * 100))
        }
        let vm = makeSUT(accounts: accounts)
        await vm.load()

        #expect(vm.previewAccounts.count == 4)
        #expect(vm.accounts.count == 6)
    }

    // MARK: - Transaction Tests

    @Test func testRecentTransactionsSortedByDateDescending() async throws {
        let now = Date()
        let transactions = [
            FinScope.Transaction(accountId: UUID(), type: .expense, amount: 10, date: now.adding(days: -3)),
            FinScope.Transaction(accountId: UUID(), type: .expense, amount: 20, date: now.adding(days: -1)),
            FinScope.Transaction(accountId: UUID(), type: .income, amount: 30, date: now)
        ]
        let vm = makeSUT(transactions: transactions)
        await vm.load()

        #expect(vm.recentTransactions.count == 3)
        #expect(vm.recentTransactions.first?.amount == 30)
        #expect(vm.recentTransactions.last?.amount == 10)
    }

    @Test func testRecentTransactionsLimitedToFive() async throws {
        let now = Date()
        let transactions = (0..<8).map { i in
            FinScope.Transaction(accountId: UUID(), type: .expense, amount: Decimal(i * 10), date: now.adding(days: -i))
        }
        let vm = makeSUT(transactions: transactions)
        await vm.load()

        #expect(vm.recentTransactions.count == 5)
    }

    // MARK: - Budget Tests

    @Test func testBudgetTotals() async throws {
        let cat1Id = UUID()
        let cat2Id = UUID()
        let budgets = [
            Budget(categoryId: cat1Id, amount: 500),
            Budget(categoryId: cat2Id, amount: 300)
        ]
        let now = Date()
        let transactions = [
            FinScope.Transaction(accountId: UUID(), type: .expense, amount: 200, categoryId: cat1Id, date: now),
            FinScope.Transaction(accountId: UUID(), type: .expense, amount: 150, categoryId: cat2Id, date: now)
        ]
        let vm = makeSUT(transactions: transactions, budgets: budgets)
        await vm.load()

        #expect(vm.totalBudgeted == 800)
        #expect(vm.totalSpent == 350)
        #expect(vm.budgetFraction > 0.43)
        #expect(vm.budgetFraction < 0.44)
    }

    @Test func testTopBudgetsSortedBySpentFractionDescending() async throws {
        let cat1Id = UUID()
        let cat2Id = UUID()
        let cat3Id = UUID()
        let cat4Id = UUID()
        let budgets = [
            Budget(categoryId: cat1Id, amount: 100),
            Budget(categoryId: cat2Id, amount: 200),
            Budget(categoryId: cat3Id, amount: 300),
            Budget(categoryId: cat4Id, amount: 400)
        ]
        let now = Date()
        let transactions = [
            FinScope.Transaction(accountId: UUID(), type: .expense, amount: 90, categoryId: cat1Id, date: now),
            FinScope.Transaction(accountId: UUID(), type: .expense, amount: 50, categoryId: cat2Id, date: now),
            FinScope.Transaction(accountId: UUID(), type: .expense, amount: 270, categoryId: cat3Id, date: now),
            FinScope.Transaction(accountId: UUID(), type: .expense, amount: 100, categoryId: cat4Id, date: now)
        ]
        let vm = makeSUT(transactions: transactions, budgets: budgets)
        await vm.load()

        #expect(vm.topBudgets.count == 3)
        #expect(vm.topBudgets[0].categoryId == cat3Id)
        #expect(vm.topBudgets[1].categoryId == cat1Id)
        #expect(vm.topBudgets[2].categoryId == cat2Id)
    }

    // MARK: - Forecast Tests

    @Test func testForecastBalanceChange() async throws {
        let accounts = [Account(name: "Bank", type: .bank, balance: 5000)]
        let forecasts = [
            MonthlyForecast(
                month: Date().adding(months: 1).startOfMonth,
                projectedIncome: 3000,
                projectedExpenses: 2000,
                netCashFlow: 1000,
                projectedBalance: 6000
            ),
            MonthlyForecast(
                month: Date().adding(months: 2).startOfMonth,
                projectedIncome: 3000,
                projectedExpenses: 2000,
                netCashFlow: 1000,
                projectedBalance: 7000
            ),
            MonthlyForecast(
                month: Date().adding(months: 3).startOfMonth,
                projectedIncome: 3000,
                projectedExpenses: 2500,
                netCashFlow: 500,
                projectedBalance: 7500
            )
        ]
        let vm = makeSUT(accounts: accounts, forecasts: forecasts)
        await vm.load()

        #expect(vm.projectedBalance == 7500)
        #expect(vm.forecastBalanceChange == 2500)
    }

    // MARK: - Error Tests

    @Test func testErrorSetsErrorMessage() async throws {
        let vm = makeSUT(shouldThrow: true)
        await vm.load()

        #expect(vm.errorMessage != nil)
    }

    // MARK: - Empty State Tests

    @Test func testEmptyStateWhenNoData() async throws {
        let vm = makeSUT()
        await vm.load()

        #expect(vm.isEmpty)
        #expect(vm.accounts.isEmpty)
        #expect(vm.transactions.isEmpty)
        #expect(vm.budgets.isEmpty)
    }
}
