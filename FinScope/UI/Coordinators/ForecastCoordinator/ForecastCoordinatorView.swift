import SwiftUI

struct ForecastCoordinatorView: View {
    @ObservedObject var coordinator: ForecastCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ForecastView(viewModel: coordinator.forecastViewModel)
                .navigationDestination(for: NavigationDestination.self) { _ in
                    Text("Not implemented")
                }
        }
    }
}
