import SwiftUI

enum BottomNavigationTab: CaseIterable {
    case dashboard
    case accounts
    case budget
    case investments
    case forecast
}

final class AppState: ObservableObject {
    @Published var selectedTab: BottomNavigationTab = .dashboard
}
