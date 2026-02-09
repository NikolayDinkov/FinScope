import SwiftUI

struct AppCoordinatorView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Tab("Dashboard", systemImage: AppTab.dashboard.icon, value: AppTab.dashboard) {
                DashboardView(viewModel: coordinator.makeDashboardViewModel())
            }

            Tab("Accounts", systemImage: AppTab.accounts.icon, value: AppTab.accounts) {
                AccountsCoordinatorView(coordinator: coordinator.accountsCoordinator)
            }

            Tab("Transactions", systemImage: AppTab.transactions.icon, value: AppTab.transactions) {
                TransactionsCoordinatorView(coordinator: coordinator.transactionsCoordinator)
            }

            Tab("Budget", systemImage: AppTab.budget.icon, value: AppTab.budget) {
                BudgetCoordinatorView(coordinator: coordinator.budgetCoordinator)
            }

            Tab("Invest", systemImage: AppTab.investment.icon, value: AppTab.investment) {
                InvestmentCoordinatorView(coordinator: coordinator.investmentCoordinator)
            }

            Tab("Forecast", systemImage: AppTab.forecast.icon, value: AppTab.forecast) {
                ForecastCoordinatorView(coordinator: coordinator.forecastCoordinator)
            }
        }
    }
}
