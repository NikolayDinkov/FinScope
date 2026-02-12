import SwiftUI

struct DashboardCoordinatorView: View {
    @ObservedObject var coordinator: DashboardCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Text("Dashboard")
                .font(.largeTitle)
                .navigationTitle("Dashboard")
                .navigationDestination(for: NavigationDestination.self) { _ in Text("Not implemented") }
        }
    }
}
