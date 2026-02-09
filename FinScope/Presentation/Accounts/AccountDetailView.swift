import SwiftUI

struct AccountDetailView: View {
    let viewModel: AccountDetailViewModel
    let coordinator: AccountsCoordinator

    var body: some View {
        List {
            Section {
                LabeledContent("Type", value: viewModel.account.type.rawValue.capitalized)
                LabeledContent("Currency", value: viewModel.account.currency)
                LabeledContent("Balance", value: viewModel.balance.formatted(currencyCode: viewModel.account.currency))
                LabeledContent("Created", value: DateFormatter.financeDate.string(from: viewModel.account.createdAt))
            }

            Section("Transactions") {
                if viewModel.transactions.isEmpty {
                    Text("No transactions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.transactions) { tx in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tx.note ?? tx.type.rawValue.capitalized)
                                    .font(.body)
                                Text(DateFormatter.financeDate.string(from: tx.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(tx.type == .income ? "+" : "-")\(tx.amount.formatted(currencyCode: viewModel.account.currency))")
                                .foregroundStyle(tx.type == .income ? .green : .red)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.account.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    coordinator.router.push(.form(viewModel.account))
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
