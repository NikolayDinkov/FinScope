import SwiftUI

struct InvestmentsCoordinatorView: View {
    @ObservedObject var coordinator: InvestmentsCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Text("Investments")
                .font(.largeTitle)
                .navigationTitle("Investments")
                .navigationDestination(for: NavigationDestination.self) { $0 }
        }
    }
}
