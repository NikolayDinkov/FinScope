import SwiftUI

struct AccountsCoordinatorView: View {
    @ObservedObject var coordinator: AccountsCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Text("Accounts")
                .font(.largeTitle)
                .navigationTitle("Accounts")
                .navigationDestination(for: NavigationDestination.self) { $0 }
        }
    }
}
