import Foundation

enum NavigationDestination: Hashable {
    // Dashboard
    case dashboardDetail

    // Accounts
    case accountDetail(accountId: UUID)
    case accountForm(accountId: UUID?)
    case transactionForm(accountId: UUID, transactionId: UUID?)
    case csvImportExport(accountId: UUID)
    case categoryManagement

    // Budget
    case budgetDetail

    // Investments
    case market
    case assetDetail(ticker: String)

    // Forecast
    case forecastDetail
}
