import SwiftUI

enum NavigationDestination {

    // Dashboard
    case dashboardDetail

    // Accounts
    case accountDetail

    // Budget
    case budgetDetail

    // Investments
    case investmentDetail

    // Forecast
    case forecastDetail
}

extension NavigationDestination: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }

    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.dashboardDetail, .dashboardDetail):
            true
        case (.accountDetail, .accountDetail):
            true
        case (.budgetDetail, .budgetDetail):
            true
        case (.investmentDetail, .investmentDetail):
            true
        case (.forecastDetail, .forecastDetail):
            true
        default:
            false
        }
    }
}

extension NavigationDestination: View {
    var body: some View {
        switch self {
        case .dashboardDetail:
            Text("Dashboard Detail")
        case .accountDetail:
            Text("Account Detail")
        case .budgetDetail:
            Text("Budget Detail")
        case .investmentDetail:
            Text("Investment Detail")
        case .forecastDetail:
            Text("Forecast Detail")
        }
    }
}
