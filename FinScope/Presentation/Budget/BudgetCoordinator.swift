import SwiftUI

@Observable
final class BudgetCoordinator {
    let router = NavigationRouter<BudgetRoute>()

    let makeOverviewViewModel: () -> BudgetOverviewViewModel
    let makeFormViewModel: (Budget?) -> BudgetFormViewModel

    init(
        makeOverviewViewModel: @escaping () -> BudgetOverviewViewModel,
        makeFormViewModel: @escaping (Budget?) -> BudgetFormViewModel
    ) {
        self.makeOverviewViewModel = makeOverviewViewModel
        self.makeFormViewModel = makeFormViewModel
    }

    @ViewBuilder
    func view(for route: BudgetRoute) -> some View {
        switch route {
        case .form(let budget):
            BudgetFormView(viewModel: makeFormViewModel(budget), coordinator: self)
        }
    }
}

struct BudgetCoordinatorView: View {
    @Bindable var coordinator: BudgetCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.router.path) {
            BudgetOverviewView(
                viewModel: coordinator.makeOverviewViewModel(),
                coordinator: coordinator
            )
            .navigationDestination(for: BudgetRoute.self) { route in
                coordinator.view(for: route)
            }
        }
    }
}
