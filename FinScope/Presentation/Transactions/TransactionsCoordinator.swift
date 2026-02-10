import SwiftUI

@MainActor @Observable
final class TransactionsCoordinator {
    var router = NavigationRouter<TransactionRoute>()

    let makeListViewModel: () -> TransactionListViewModel
    let makeFormViewModel: (Transaction?) -> TransactionFormViewModel

    init(
        makeListViewModel: @escaping () -> TransactionListViewModel,
        makeFormViewModel: @escaping (Transaction?) -> TransactionFormViewModel
    ) {
        self.makeListViewModel = makeListViewModel
        self.makeFormViewModel = makeFormViewModel
    }

    @ViewBuilder
    func view(for route: TransactionRoute) -> some View {
        switch route {
        case .form(let transaction):
            TransactionFormView(viewModel: makeFormViewModel(transaction), coordinator: self)
        case .csvImport(let account):
            CSVImportView(account: account, coordinator: self)
        }
    }
}

struct TransactionsCoordinatorView: View {
    @Bindable var coordinator: TransactionsCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.router.path) {
            TransactionListView(
                viewModel: coordinator.makeListViewModel(),
                coordinator: coordinator
            )
            .navigationDestination(for: TransactionRoute.self) { route in
                coordinator.view(for: route)
            }
        }
    }
}
