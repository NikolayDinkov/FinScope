import SwiftUI

struct BudgetCoordinatorView: View {
    @ObservedObject var coordinator: BudgetCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            BudgetListView(viewModel: coordinator.budgetListViewModel)
                .navigationDestination(for: NavigationDestination.self) { _ in
                    Text("Not implemented")
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .budgetForm(let budgetId):
                BudgetFormView(viewModel: coordinator.makeBudgetFormViewModel(budgetId: budgetId))
            }
        }
    }
}
