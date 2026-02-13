import Foundation
import Combine

@MainActor @Observable
final class BudgetListViewModel {
    var budgets: [Budget] = []
    var spending: [UUID: Decimal] = [:]
    var categories: [Category] = []
    var selectedMonth: Date = Date()
    var errorMessage: String?
    var isLoading = false

    var onAddBudget: (() -> Void)?
    var onSelectBudget: ((UUID) -> Void)?

    private let fetchBudgetsUseCase: FetchBudgetsUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let fetchCategorySpendingUseCase: FetchCategorySpendingUseCase
    private let deleteBudgetUseCase: DeleteBudgetUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchBudgetsUseCase: FetchBudgetsUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        fetchCategorySpendingUseCase: FetchCategorySpendingUseCase,
        deleteBudgetUseCase: DeleteBudgetUseCase
    ) {
        self.fetchBudgetsUseCase = fetchBudgetsUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.fetchCategorySpendingUseCase = fetchCategorySpendingUseCase
        self.deleteBudgetUseCase = deleteBudgetUseCase

        NotificationCenter.default.publisher(for: .dataDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.load() }
            }
            .store(in: &cancellables)
    }

    var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    var totalBudgeted: Decimal {
        budgets.reduce(0) { $0 + $1.amount }
    }

    var totalSpent: Decimal {
        budgets.reduce(0) { $0 + spentAmount(for: $1) }
    }

    var totalRemaining: Decimal {
        totalBudgeted - totalSpent
    }

    func spentAmount(for budget: Budget) -> Decimal {
        spending[budget.categoryId] ?? 0
    }

    func spentFraction(for budget: Budget) -> Double {
        guard budget.amount > 0 else { return 0 }
        let fraction = NSDecimalNumber(decimal: spentAmount(for: budget) / budget.amount).doubleValue
        return min(max(fraction, 0), 1.5)
    }

    func categoryName(for budget: Budget) -> String {
        categories.first { $0.id == budget.categoryId }?.name ?? ""
    }

    func categoryIcon(for budget: Budget) -> String {
        categories.first { $0.id == budget.categoryId }?.icon ?? "circle.fill"
    }

    func categoryColorHex(for budget: Budget) -> String {
        categories.first { $0.id == budget.categoryId }?.colorHex ?? "#007AFF"
    }

    func load() async {
        isLoading = true
        do {
            budgets = try await fetchBudgetsUseCase.execute()
            categories = try await fetchCategoriesUseCase.execute(type: .expense)
            spending = try await fetchCategorySpendingUseCase.execute(
                from: startOfMonth,
                to: endOfMonth
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteBudget(id: UUID) async {
        do {
            try await deleteBudgetUseCase.execute(id: id)
            budgets.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func goToPreviousMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) else { return }
        selectedMonth = newDate
        Task { await load() }
    }

    func goToNextMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) else { return }
        selectedMonth = newDate
        Task { await load() }
    }

    private var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: selectedMonth)?.start ?? selectedMonth
    }

    private var endOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: selectedMonth)?.end ?? selectedMonth
    }
}
