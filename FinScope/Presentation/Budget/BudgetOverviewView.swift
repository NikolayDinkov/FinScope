import SwiftUI

struct BudgetOverviewView: View {
    let viewModel: BudgetOverviewViewModel
    let coordinator: BudgetCoordinator

    var body: some View {
        List {
            if !viewModel.alerts.isEmpty {
                Section("Alerts") {
                    ForEach(viewModel.alerts, id: \.rule.id) { alert in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            VStack(alignment: .leading) {
                                Text("Over budget!")
                                    .font(.headline)
                                Text("Spent \(alert.currentSpending.currencyFormatted) of \(alert.limit.currencyFormatted)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            if viewModel.budgets.isEmpty {
                EmptyStateView(
                    icon: "chart.pie",
                    title: "No Budgets",
                    message: "Create a budget to track your spending"
                )
                .listRowBackground(Color.clear)
            }

            ForEach(viewModel.budgets) { budget in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(budget.name)
                            .font(.headline)
                        Spacer()
                        Text(budget.period.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let status = viewModel.budgetStatuses[budget.id] {
                        if let limit = budget.totalLimit {
                            ProgressView(
                                value: min(status.totalSpending.doubleValue / limit.doubleValue, 1.0)
                            )
                            .tint(status.isOverBudget ? .red : .blue)

                            Text("\(status.totalSpending.currencyFormatted) / \(limit.currencyFormatted)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Budget")
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
