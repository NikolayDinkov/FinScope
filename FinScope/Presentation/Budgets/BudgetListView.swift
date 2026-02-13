import SwiftUI

struct BudgetListView: View {
    @Bindable var viewModel: BudgetListViewModel

    var body: some View {
        List {
            if !viewModel.budgets.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            Button(action: { viewModel.goToPreviousMonth() }) {
                                Image(systemName: "chevron.left")
                                    .font(.body.weight(.semibold))
                            }
                            .buttonStyle(.borderless)
                            Spacer()
                            Text(viewModel.monthLabel)
                                .font(.headline)
                            Spacer()
                            Button(action: { viewModel.goToNextMonth() }) {
                                Image(systemName: "chevron.right")
                                    .font(.body.weight(.semibold))
                            }
                            .buttonStyle(.borderless)
                        }

                        VStack(spacing: 4) {
                            Text(viewModel.totalSpent.currencyFormatted())
                                .font(.title2.bold().monospacedDigit())
                            Text("of \(viewModel.totalBudgeted.currencyFormatted()) budgeted")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        BudgetProgressBar(
                            spent: viewModel.totalSpent,
                            limit: viewModel.totalBudgeted
                        )
                    }
                    .padding(.vertical, 4)
                }

                Section("Budgets") {
                    ForEach(viewModel.budgets) { budget in
                        BudgetRowView(
                            categoryName: viewModel.categoryName(for: budget),
                            categoryIcon: viewModel.categoryIcon(for: budget),
                            categoryColorHex: viewModel.categoryColorHex(for: budget),
                            spent: viewModel.spentAmount(for: budget),
                            limit: budget.amount,
                            fraction: viewModel.spentFraction(for: budget)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.onSelectBudget?(budget.id)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let budget = viewModel.budgets[index]
                            Task {
                                await viewModel.deleteBudget(id: budget.id)
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            if viewModel.budgets.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "No Budgets",
                    systemImage: "chart.pie",
                    description: Text("Set spending limits for your expense categories.")
                )
            }
        }
        .navigationTitle("Budget")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.onAddBudget?() }) {
                    Image(systemName: "plus")
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

// MARK: - Budget Row

private struct BudgetRowView: View {
    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    let spent: Decimal
    let limit: Decimal
    let fraction: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                CircularIcon(systemName: categoryIcon, color: Color(hex: categoryColorHex))

                Text(categoryName)
                    .font(.body.weight(.medium))

                Spacer()

                Text("\(spent.currencyFormatted()) / \(limit.currencyFormatted())")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            GradientProgressBar(fraction: fraction)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Progress Bar

private struct BudgetProgressBar: View {
    let spent: Decimal
    let limit: Decimal

    private var fraction: Double {
        guard limit > 0 else { return 0 }
        return NSDecimalNumber(decimal: spent / limit).doubleValue
    }

    var body: some View {
        GradientProgressBar(fraction: fraction)
    }
}
