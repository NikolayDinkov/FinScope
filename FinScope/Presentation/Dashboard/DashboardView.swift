import SwiftUI

struct DashboardView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Net worth card
                    VStack(spacing: 8) {
                        Text("Net Worth")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(viewModel.totalBalance.currencyFormatted)
                            .font(.largeTitle.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Monthly summary
                    HStack(spacing: 16) {
                        SummaryCard(
                            title: "Income",
                            amount: viewModel.monthlyIncome,
                            color: .green
                        )
                        SummaryCard(
                            title: "Expenses",
                            amount: viewModel.monthlyExpenses,
                            color: .red
                        )
                    }

                    // Accounts overview
                    if !viewModel.accounts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Accounts")
                                .font(.headline)

                            ForEach(viewModel.accounts) { account in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(account.name)
                                            .font(.body)
                                        Text(account.type.rawValue.capitalized)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(account.currency)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // Recent transactions
                    if !viewModel.recentTransactions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Transactions")
                                .font(.headline)

                            ForEach(viewModel.recentTransactions.prefix(5)) { tx in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(tx.note ?? tx.type.rawValue.capitalized)
                                            .font(.body)
                                        Text(DateFormatter.financeDate.string(from: tx.date))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("\(tx.type == .income ? "+" : "-")\(tx.amount.currencyFormatted)")
                                        .foregroundStyle(tx.type == .income ? .green : .red)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    if viewModel.accounts.isEmpty && viewModel.recentTransactions.isEmpty {
                        EmptyStateView(
                            icon: "chart.bar.doc.horizontal",
                            title: "Welcome to FinScope",
                            message: "Add your first account to get started"
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .task {
                await viewModel.load()
            }
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let amount: Decimal
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount.currencyFormatted)
                .font(.title3.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
