import SwiftUI

@Observable
final class InvestmentCoordinator {
    let router = NavigationRouter<InvestmentRoute>()

    let makeListViewModel: () -> PortfolioListViewModel
    let makeSimulatorViewModel: (Portfolio) -> SimulatorViewModel

    init(
        makeListViewModel: @escaping () -> PortfolioListViewModel,
        makeSimulatorViewModel: @escaping (Portfolio) -> SimulatorViewModel
    ) {
        self.makeListViewModel = makeListViewModel
        self.makeSimulatorViewModel = makeSimulatorViewModel
    }

    @ViewBuilder
    func view(for route: InvestmentRoute) -> some View {
        switch route {
        case .simulator(let portfolio):
            SimulatorView(viewModel: makeSimulatorViewModel(portfolio))
        case .assetForm(let portfolio):
            AssetFormView(portfolio: portfolio)
        }
    }
}

struct InvestmentCoordinatorView: View {
    @Bindable var coordinator: InvestmentCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.router.path) {
            PortfolioListView(
                viewModel: coordinator.makeListViewModel(),
                coordinator: coordinator
            )
            .navigationDestination(for: InvestmentRoute.self) { route in
                coordinator.view(for: route)
            }
        }
    }
}
