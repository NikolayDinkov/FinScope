import SwiftUI

struct AccountDetailView: View {
    @Bindable var viewModel: AccountDetailViewModel

    var body: some View {
        List {
            if let account = viewModel.account {
                Section {
                    VStack(spacing: 8) {
                        Text(account.balance.currencyFormatted(code: account.currencyCode))
                            .font(.system(size: 34, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(account.balance >= 0 ? Color.primary : Color.red)
                        Text(account.type.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }

                Section("Transactions") {
                    if viewModel.transactions.isEmpty {
                        Text("No transactions yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.transactions) { transaction in
                            TransactionRowView(
                                transaction: transaction,
                                categoryName: viewModel.categoryName(for: transaction.categoryId),
                                categoryIcon: viewModel.categoryIcon(for: transaction.categoryId),
                                categoryColorHex: viewModel.categoryColorHex(for: transaction.categoryId),
                                viewingAccountId: viewModel.accountId
                            )
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let transaction = viewModel.transactions[index]
                                Task {
                                    await viewModel.deleteTransaction(id: transaction.id)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.account?.name ?? "Account")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { viewModel.onEditAccount?() }) {
                        Label("Edit Account", systemImage: "pencil")
                    }
                    Button(action: { viewModel.onAddTransaction?() }) {
                        Label("Add Transaction", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.load()
        }
    }
}
