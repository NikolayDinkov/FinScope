import SwiftUI

struct ForecastCoordinatorView: View {
    @ObservedObject var coordinator: ForecastCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Text("Forecast")
                .font(.largeTitle)
                .navigationTitle("Forecast")
                .navigationDestination(for: NavigationDestination.self) { $0 }
        }
    }
}
