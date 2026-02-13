import Foundation
import Combine

@MainActor @Observable
final class DashboardViewModel {
    var accounts: [Account] = []
    var transactions: [Transaction] = []
    var budgets: [Budget] = []
    var categories: [Category] = []
    var spending: [UUID: Decimal] = [:]
    var forecasts: [MonthlyForecast] = []
    var errorMessage: String?
    var isLoading = false

    private let fetchAccountsUseCase: FetchAccountsUseCase
    private let fetchTransactionsUseCase: FetchTransactionsUseCase
    private let fetchBudgetsUseCase: FetchBudgetsUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let fetchCategorySpendingUseCase: FetchCategorySpendingUseCase
    private let generateForecastUseCase: GenerateForecastUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchAccountsUseCase: FetchAccountsUseCase,
        fetchTransactionsUseCase: FetchTransactionsUseCase,
        fetchBudgetsUseCase: FetchBudgetsUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        fetchCategorySpendingUseCase: FetchCategorySpendingUseCase,
        generateForecastUseCase: GenerateForecastUseCase
    ) {
        self.fetchAccountsUseCase = fetchAccountsUseCase
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
        self.fetchBudgetsUseCase = fetchBudgetsUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.fetchCategorySpendingUseCase = fetchCategorySpendingUseCase
        self.generateForecastUseCase = generateForecastUseCase

        NotificationCenter.default.publisher(for: .dataDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.load() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Balance

    var totalBalance: Decimal {
        accounts.reduce(Decimal.zero) { $0 + $1.balance }
    }

    var previewAccounts: [Account] {
        Array(accounts.prefix(4))
    }

    // MARK: - Budget

    var totalBudgeted: Decimal {
        budgets.reduce(Decimal.zero) { $0 + $1.amount }
    }

    var totalSpent: Decimal {
        budgets.reduce(Decimal.zero) { $0 + (spending[$1.categoryId] ?? 0) }
    }

    var budgetFraction: Double {
        guard totalBudgeted > 0 else { return 0 }
        return NSDecimalNumber(decimal: totalSpent / totalBudgeted).doubleValue
    }

    var topBudgets: [Budget] {
        budgets
            .sorted { spentFraction(for: $0) > spentFraction(for: $1) }
            .prefix(3)
            .map { $0 }
    }

    func spentAmount(for budget: Budget) -> Decimal {
        spending[budget.categoryId] ?? 0
    }

    func spentFraction(for budget: Budget) -> Double {
        guard budget.amount > 0 else { return 0 }
        let fraction = NSDecimalNumber(decimal: spentAmount(for: budget) / budget.amount).doubleValue
        return min(max(fraction, 0), 1.5)
    }

    func categoryName(for categoryId: UUID) -> String {
        categories.first { $0.id == categoryId }?.name ?? ""
    }

    func categoryIcon(for categoryId: UUID) -> String {
        categories.first { $0.id == categoryId }?.icon ?? "circle.fill"
    }

    func categoryColorHex(for categoryId: UUID) -> String {
        categories.first { $0.id == categoryId }?.colorHex ?? "#007AFF"
    }

    // MARK: - Transactions

    var recentTransactions: [Transaction] {
        Array(
            transactions
                .sorted { $0.date > $1.date }
                .prefix(5)
        )
    }

    // MARK: - Forecast

    var projectedBalance: Decimal {
        forecasts.last?.projectedBalance ?? totalBalance
    }

    var forecastBalanceChange: Decimal {
        projectedBalance - totalBalance
    }

    // MARK: - Empty State

    var isEmpty: Bool {
        accounts.isEmpty && transactions.isEmpty && budgets.isEmpty
    }

    // MARK: - Load

    func load() async {
        isLoading = true
        do {
            let now = Date()
            let startOfMonth = now.startOfMonth
            let endOfMonth = now.endOfMonth

            async let fetchedAccounts = fetchAccountsUseCase.execute()
            async let fetchedTransactions = fetchTransactionsUseCase.execute()
            async let fetchedBudgets = fetchBudgetsUseCase.execute()
            async let fetchedCategories = fetchCategoriesUseCase.execute()
            async let fetchedSpending = fetchCategorySpendingUseCase.execute(from: startOfMonth, to: endOfMonth)
            async let fetchedForecasts = generateForecastUseCase.execute(horizon: .threeMonths)

            accounts = try await fetchedAccounts
            transactions = try await fetchedTransactions
            budgets = try await fetchedBudgets
            categories = try await fetchedCategories
            spending = try await fetchedSpending
            forecasts = try await fetchedForecasts
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
