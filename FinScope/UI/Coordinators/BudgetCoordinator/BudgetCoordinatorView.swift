import SwiftUI

struct BudgetCoordinatorView: View {
    @ObservedObject var coordinator: BudgetCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Text("Budget")
                .font(.largeTitle)
                .navigationTitle("Budget")
                .navigationDestination(for: NavigationDestination.self) { _ in Text("Not implemented") }
        }
    }
}
