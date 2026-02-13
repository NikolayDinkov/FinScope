import SwiftUI

struct DashboardCoordinatorView: View {
    @ObservedObject var coordinator: DashboardCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            DashboardView(viewModel: coordinator.dashboardViewModel)
                .navigationDestination(for: NavigationDestination.self) { _ in
                    Text("Not implemented")
                }
        }
    }
}
