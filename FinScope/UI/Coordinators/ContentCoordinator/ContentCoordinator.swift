import SwiftUI

final class ContentCoordinator: Coordinator, ObservableObject {
    let tabBarItems: [BottomNavigationTab] = BottomNavigationTab.allCases
    var appState: AppState

    @MainActor private lazy var dashboardCoordinator = DashboardCoordinator()
    @MainActor private lazy var accountsCoordinator = AccountsCoordinator()
    @MainActor private lazy var budgetCoordinator = BudgetCoordinator()
    @MainActor private lazy var investmentsCoordinator = InvestmentsCoordinator()
    @MainActor private lazy var forecastCoordinator = ForecastCoordinator()

    init(appState: AppState) {
        self.appState = appState
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
