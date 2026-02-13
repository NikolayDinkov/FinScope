import SwiftUI

@MainActor
final class DashboardCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()

    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let budgetRepository: BudgetRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol
    private let forecastService: ForecastServiceProtocol

    init(
        accountRepository: AccountRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol,
        budgetRepository: BudgetRepositoryProtocol,
        categoryRepository: CategoryRepositoryProtocol,
        forecastService: ForecastServiceProtocol
    ) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository
        self.categoryRepository = categoryRepository
        self.forecastService = forecastService
    }

    private(set) lazy var dashboardViewModel: DashboardViewModel = makeDashboardViewModel()

    func start() -> some View {
        DashboardCoordinatorView(coordinator: self)
    }

    private func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            fetchAccountsUseCase: FetchAccountsUseCase(repository: accountRepository),
            fetchTransactionsUseCase: FetchTransactionsUseCase(repository: transactionRepository),
            fetchBudgetsUseCase: FetchBudgetsUseCase(repository: budgetRepository),
            fetchCategoriesUseCase: FetchCategoriesUseCase(repository: categoryRepository),
            fetchCategorySpendingUseCase: FetchCategorySpendingUseCase(transactionRepository: transactionRepository),
            generateForecastUseCase: GenerateForecastUseCase(
                accountRepository: accountRepository,
                transactionRepository: transactionRepository,
                forecastService: forecastService
            )
        )
    }
}
