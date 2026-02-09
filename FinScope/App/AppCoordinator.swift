import Foundation

@Observable
final class AppCoordinator {
    let accountsCoordinator: AccountsCoordinator
    let transactionsCoordinator: TransactionsCoordinator
    let budgetCoordinator: BudgetCoordinator
    let investmentCoordinator: InvestmentCoordinator
    let forecastCoordinator: ForecastCoordinator

    // Dashboard ViewModel factory
    let makeDashboardViewModel: () -> DashboardViewModel

    var selectedTab: AppTab = .dashboard

    init(
        accountsCoordinator: AccountsCoordinator,
        transactionsCoordinator: TransactionsCoordinator,
        budgetCoordinator: BudgetCoordinator,
        investmentCoordinator: InvestmentCoordinator,
        forecastCoordinator: ForecastCoordinator,
        makeDashboardViewModel: @escaping () -> DashboardViewModel
    ) {
        self.accountsCoordinator = accountsCoordinator
        self.transactionsCoordinator = transactionsCoordinator
        self.budgetCoordinator = budgetCoordinator
        self.investmentCoordinator = investmentCoordinator
        self.forecastCoordinator = forecastCoordinator
        self.makeDashboardViewModel = makeDashboardViewModel
    }
}
