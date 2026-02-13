import SwiftUI

@MainActor
final class BudgetCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()
    @Published var sheet: BudgetSheet?

    enum BudgetSheet: Identifiable {
        case budgetForm(budgetId: UUID?)

        var id: String {
            switch self {
            case .budgetForm(let id): "budgetForm-\(id?.uuidString ?? "new")"
            }
        }
    }

    private let budgetRepository: BudgetRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol

    init(
        budgetRepository: BudgetRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol,
        categoryRepository: CategoryRepositoryProtocol
    ) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
        self.categoryRepository = categoryRepository
    }

    private(set) lazy var budgetListViewModel: BudgetListViewModel = makeBudgetListViewModel()

    func start() -> some View {
        BudgetCoordinatorView(coordinator: self)
    }

    // MARK: - View Model Factories

    private func makeBudgetListViewModel() -> BudgetListViewModel {
        let vm = BudgetListViewModel(
            fetchBudgetsUseCase: FetchBudgetsUseCase(repository: budgetRepository),
            fetchCategoriesUseCase: FetchCategoriesUseCase(repository: categoryRepository),
            fetchCategorySpendingUseCase: FetchCategorySpendingUseCase(transactionRepository: transactionRepository),
            deleteBudgetUseCase: DeleteBudgetUseCase(repository: budgetRepository)
        )
        vm.onAddBudget = { [weak self] in
            self?.sheet = .budgetForm(budgetId: nil)
        }
        vm.onSelectBudget = { [weak self] id in
            self?.sheet = .budgetForm(budgetId: id)
        }
        return vm
    }

    func makeBudgetFormViewModel(budgetId: UUID?) -> BudgetFormViewModel {
        var editingBudget: Budget?
        if let budgetId {
            editingBudget = budgetListViewModel.budgets.first { $0.id == budgetId }
        }
        let vm = BudgetFormViewModel(
            editingBudget: editingBudget,
            fetchCategoriesUseCase: FetchCategoriesUseCase(repository: categoryRepository),
            fetchBudgetsUseCase: FetchBudgetsUseCase(repository: budgetRepository),
            createBudgetUseCase: CreateBudgetUseCase(repository: budgetRepository),
            updateBudgetUseCase: UpdateBudgetUseCase(repository: budgetRepository)
        )
        vm.onSave = { [weak self] in self?.sheet = nil }
        vm.onCancel = { [weak self] in self?.sheet = nil }
        return vm
    }
}
