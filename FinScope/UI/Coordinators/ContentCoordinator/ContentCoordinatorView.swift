import SwiftUI

struct ContentCoordinatorView: View {
    @ObservedObject var coordinator: ContentCoordinator

    var body: some View {
        TabView(selection: $coordinator.appState.selectedTab) {
            ForEach(coordinator.tabBarItems, id: \.self) { tab in
                coordinator.tabView(for: tab)
                    .tabItem {
                        tab.image
                        Text(tab.title)
                    }
                    .tag(tab)
            }
        }
    }
}

extension BottomNavigationTab {
    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .accounts: "Accounts"
        case .budget: "Budget"
        case .investments: "Investments"
        case .forecast: "Forecast"
        }
    }

    var image: Image {
        switch self {
        case .dashboard: Image(systemName: "house.fill")
        case .accounts: Image(systemName: "creditcard.fill")
        case .budget: Image(systemName: "chart.pie.fill")
        case .investments: Image(systemName: "chart.line.uptrend.xyaxis")
        case .forecast: Image(systemName: "chart.bar.fill")
        }
    }
}
