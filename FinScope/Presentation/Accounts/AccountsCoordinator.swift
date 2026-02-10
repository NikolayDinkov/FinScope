import SwiftUI

@MainActor @Observable
final class AccountsCoordinator {
    var router = NavigationRouter<AccountRoute>()

    let makeListViewModel: () -> AccountListViewModel
    let makeDetailViewModel: (Account) -> AccountDetailViewModel
    let makeFormViewModel: (Account?) -> AccountFormViewModel

    init(
        makeListViewModel: @escaping () -> AccountListViewModel,
        makeDetailViewModel: @escaping (Account) -> AccountDetailViewModel,
        makeFormViewModel: @escaping (Account?) -> AccountFormViewModel
    ) {
        self.makeListViewModel = makeListViewModel
        self.makeDetailViewModel = makeDetailViewModel
        self.makeFormViewModel = makeFormViewModel
    }

    @ViewBuilder
    func view(for route: AccountRoute) -> some View {
        switch route {
        case .detail(let account):
            AccountDetailView(viewModel: makeDetailViewModel(account), coordinator: self)
        case .form(let account):
            AccountFormView(viewModel: makeFormViewModel(account), coordinator: self)
        }
    }
}

struct AccountsCoordinatorView: View {
    @Bindable var coordinator: AccountsCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.router.path) {
            AccountListView(
                viewModel: coordinator.makeListViewModel(),
                coordinator: coordinator
            )
            .navigationDestination(for: AccountRoute.self) { route in
                coordinator.view(for: route)
            }
        }
    }
}
