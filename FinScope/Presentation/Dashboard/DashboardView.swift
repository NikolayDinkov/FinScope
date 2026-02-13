import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel

    var body: some View {
        List {
            if !viewModel.isEmpty {
                balanceSection
                budgetSection
                transactionsSection
                forecastSection
            }
        }
        .overlay {
            if viewModel.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "No Data Yet",
                    systemImage: "chart.bar.doc.horizontal",
                    description: Text("Add accounts and transactions to see your financial overview.")
                )
            }
        }
        .navigationTitle("Dashboard")
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

    // MARK: - Balance Section

    @ViewBuilder
    private var balanceSection: some View {
        if !viewModel.accounts.isEmpty {
            Section("Total Balance") {
                VStack(spacing: 4) {
                    Text(viewModel.totalBalance.currencyFormatted())
                        .font(.title.bold().monospacedDigit())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)

                ForEach(viewModel.previewAccounts) { account in
                    DashboardAccountRowView(account: account)
                }

                if viewModel.accounts.count > 4 {
                    Text("\(viewModel.accounts.count - 4) more accounts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Budget Section

    @ViewBuilder
    private var budgetSection: some View {
        if !viewModel.budgets.isEmpty {
            Section("Budget This Month") {
                DashboardBudgetSummaryView(
                    totalSpent: viewModel.totalSpent,
                    totalBudgeted: viewModel.totalBudgeted,
                    budgetFraction: viewModel.budgetFraction,
                    topBudgets: viewModel.topBudgets,
                    spentAmount: viewModel.spentAmount(for:),
                    spentFraction: viewModel.spentFraction(for:),
                    categoryName: viewModel.categoryName(for:),
                    categoryIcon: viewModel.categoryIcon(for:),
                    categoryColorHex: viewModel.categoryColorHex(for:)
                )
            }
        }
    }

    // MARK: - Transactions Section

    @ViewBuilder
    private var transactionsSection: some View {
        if !viewModel.recentTransactions.isEmpty {
            Section("Recent Transactions") {
                ForEach(viewModel.recentTransactions) { transaction in
                    DashboardTransactionRowView(
                        transaction: transaction,
                        categoryName: viewModel.categoryName(for: transaction.categoryId ?? UUID()),
                        categoryIcon: viewModel.categoryIcon(for: transaction.categoryId ?? UUID()),
                        categoryColorHex: viewModel.categoryColorHex(for: transaction.categoryId ?? UUID())
                    )
                }
            }
        }
    }

    // MARK: - Forecast Section

    @ViewBuilder
    private var forecastSection: some View {
        if !viewModel.forecasts.isEmpty {
            Section("3-Month Forecast") {
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(viewModel.totalBalance.currencyFormatted())
                                .font(.headline.monospacedDigit())
                        }

                        Spacer()

                        Image(systemName: viewModel.forecastBalanceChange >= 0
                              ? "arrow.right" : "arrow.right")
                            .foregroundStyle(.secondary)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Projected")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(viewModel.projectedBalance.currencyFormatted())
                                .font(.headline.monospacedDigit())
                        }
                    }

                    HStack(spacing: 4) {
                        Image(systemName: viewModel.forecastBalanceChange >= 0
                              ? "arrow.up.right" : "arrow.down.right")
                        Text(viewModel.forecastBalanceChange.currencyFormatted())
                    }
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(viewModel.forecastBalanceChange >= 0 ? .green : .red)
                }
                .padding(.vertical, 4)
            }
        }
    }
}
