import SwiftUI

struct AccountsCoordinatorView: View {
    @ObservedObject var coordinator: AccountsCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            AccountListView(viewModel: coordinator.accountListViewModel)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .accountDetail(let accountId):
                        AccountDetailView(viewModel: coordinator.accountDetailViewModel(for: accountId))
                    default:
                        Text("Not implemented")
                    }
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .accountForm(let accountId):
                AccountFormView(viewModel: coordinator.makeAccountFormViewModel(accountId: accountId))
            case .transactionForm(let accountId, let transactionId):
                TransactionFormView(viewModel: coordinator.makeTransactionFormViewModel(accountId: accountId, transactionId: transactionId))
            case .csvImportExport(let accountId):
                CSVImportExportView(viewModel: coordinator.makeCSVImportExportViewModel(accountId: accountId))
            case .categoryManagement:
                CategoryListView(viewModel: coordinator.makeCategoryListViewModel())
            case .categoryForm:
                CategoryFormView(
                    onSave: { category in
                        Task { await coordinator.createCategory(category) }
                    },
                    onCancel: { coordinator.sheet = nil }
                )
            }
        }
    }
}
