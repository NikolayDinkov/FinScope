import SwiftUI

struct TransactionListView: View {
    let viewModel: TransactionListViewModel
    let coordinator: TransactionsCoordinator

    var body: some View {
        List {
            if viewModel.transactions.isEmpty {
                EmptyStateView(
                    icon: "arrow.left.arrow.right",
                    title: "No Transactions",
                    message: "Tap + to add your first transaction"
                )
                .listRowBackground(Color.clear)
            }

            ForEach(viewModel.transactions) { tx in
                HStack {
                    VStack(alignment: .leading) {
                        Text(tx.note ?? tx.type.rawValue.capitalized)
                            .font(.headline)
                        Text(DateFormatter.financeDate.string(from: tx.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(tx.type == .income ? "+" : "-")\(tx.amount.currencyFormatted)")
                        .font(.body.monospacedDigit())
                        .foregroundStyle(tx.type == .income ? .green : .red)
                }
            }
        }
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    coordinator.router.push(.form(nil))
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
