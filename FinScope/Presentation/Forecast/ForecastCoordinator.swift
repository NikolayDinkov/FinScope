import SwiftUI

@MainActor @Observable
final class ForecastCoordinator {
    var router = NavigationRouter<ForecastRoute>()

    let makeViewModel: () -> ForecastViewModel

    init(makeViewModel: @escaping () -> ForecastViewModel) {
        self.makeViewModel = makeViewModel
    }

    @ViewBuilder
    func view(for route: ForecastRoute) -> some View {
        switch route {
        case .comparison(let forecasts):
            ScenarioComparisonView(forecasts: forecasts)
        }
    }
}

struct ForecastCoordinatorView: View {
    @Bindable var coordinator: ForecastCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.router.path) {
            ForecastView(
                viewModel: coordinator.makeViewModel(),
                coordinator: coordinator
            )
            .navigationDestination(for: ForecastRoute.self) { route in
                coordinator.view(for: route)
            }
        }
    }
}
