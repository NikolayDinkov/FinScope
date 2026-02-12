import SwiftUI

@MainActor
final class ContentCoordinator: Coordinator, ObservableObject {
    let tabBarItems: [BottomNavigationTab] = BottomNavigationTab.allCases
    var appState: AppState

    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol
    private let subcategoryRepository: SubcategoryRepositoryProtocol

    @MainActor private lazy var dashboardCoordinator = DashboardCoordinator()
    @MainActor private lazy var accountsCoordinator = AccountsCoordinator(
        accountRepository: accountRepository,
        transactionRepository: transactionRepository,
        categoryRepository: categoryRepository,
        subcategoryRepository: subcategoryRepository
    )
    @MainActor private lazy var budgetCoordinator = BudgetCoordinator()
    @MainActor private lazy var investmentsCoordinator = InvestmentsCoordinator()
    @MainActor private lazy var forecastCoordinator = ForecastCoordinator()

    init(
        appState: AppState,
        accountRepository: AccountRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol,
        categoryRepository: CategoryRepositoryProtocol,
        subcategoryRepository: SubcategoryRepositoryProtocol
    ) {
        self.appState = appState
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.categoryRepository = categoryRepository
        self.subcategoryRepository = subcategoryRepository
    }

    func start() -> some View {
        ContentCoordinatorView(coordinator: self)
    }

    @MainActor
    @ViewBuilder func tabView(for tab: BottomNavigationTab) -> some View {
        switch tab {
        case .dashboard:
            dashboardCoordinator.start()
        case .accounts:
            accountsCoordinator.start()
        case .budget:
            budgetCoordinator.start()
        case .investments:
            investmentsCoordinator.start()
        case .forecast:
            forecastCoordinator.start()
        }
    }
}
