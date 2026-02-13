import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel

    var body: some View {
        ScrollView {
            if !viewModel.isEmpty {
                VStack(spacing: FinScopeTheme.sectionSpacing) {
                    balanceSection
                    accountsSection
                    budgetSection
                    transactionsSection
                    forecastSection
                }
                .padding(.horizontal)
                .padding(.bottom, FinScopeTheme.sectionSpacing)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
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

    // MARK: - Hero Balance Card

    @ViewBuilder
    private var balanceSection: some View {
        if !viewModel.accounts.isEmpty {
            VStack(spacing: 8) {
                Text("Total Balance")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))

                Text(viewModel.totalBalance.currencyFormatted())
                    .font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)

                if !viewModel.forecasts.isEmpty {
                    ChangeIndicator(
                        value: viewModel.forecastBalanceChange,
                        formatted: viewModel.forecastBalanceChange.currencyFormatted(),
                        font: .subheadline.weight(.medium).monospacedDigit()
                    )
                    .colorScheme(.dark)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, FinScopeTheme.cardPadding)
            .background(FinScopeTheme.primaryGradient, in: RoundedRectangle(cornerRadius: FinScopeTheme.cardCornerRadius))
        }
    }

    // MARK: - Accounts Section

    @ViewBuilder
    private var accountsSection: some View {
        if !viewModel.accounts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Accounts")

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.previewAccounts.enumerated()), id: \.element.id) { index, account in
                        DashboardAccountRowView(account: account)
                        if index < viewModel.previewAccounts.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }

                    if viewModel.accounts.count > 4 {
                        Divider().padding(.leading, 52)
                        Text("\(viewModel.accounts.count - 4) more accounts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .cardStyle()
        }
    }

    // MARK: - Budget Section

    @ViewBuilder
    private var budgetSection: some View {
        if !viewModel.budgets.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Budget This Month")

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
            .cardStyle()
        }
    }

    // MARK: - Transactions Section

    @ViewBuilder
    private var transactionsSection: some View {
        if !viewModel.recentTransactions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Recent Transactions")

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                        DashboardTransactionRowView(
                            transaction: transaction,
                            categoryName: viewModel.categoryName(for: transaction.categoryId ?? UUID()),
                            categoryIcon: viewModel.categoryIcon(for: transaction.categoryId ?? UUID()),
                            categoryColorHex: viewModel.categoryColorHex(for: transaction.categoryId ?? UUID())
                        )
                        if index < viewModel.recentTransactions.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
            }
            .cardStyle()
        }
    }

    // MARK: - Forecast Section

    @ViewBuilder
    private var forecastSection: some View {
        if !viewModel.forecasts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Forecast")

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(viewModel.totalBalance.currencyFormatted())
                            .font(.headline.bold().monospacedDigit())
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundStyle(.tertiary)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Projected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(viewModel.projectedBalance.currencyFormatted())
                            .font(.headline.bold().monospacedDigit())
                    }
                }

                // Sparkline from forecast data
                let forecastTicks = viewModel.forecasts.enumerated().map { index, forecast in
                    PriceTick(
                        ticker: "forecast",
                        price: forecast.projectedBalance,
                        timestamp: forecast.month
                    )
                }
                SparklineView(
                    ticks: forecastTicks,
                    lineColor: viewModel.forecastBalanceChange >= 0 ? .green : .red
                )
                .frame(height: 60)

                ChangeIndicator(
                    value: viewModel.forecastBalanceChange,
                    formatted: viewModel.forecastBalanceChange.currencyFormatted(),
                    showBackground: true
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .cardStyle()
        }
    }
}
