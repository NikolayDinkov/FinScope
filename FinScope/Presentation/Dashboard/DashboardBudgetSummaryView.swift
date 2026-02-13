import SwiftUI

struct DashboardBudgetSummaryView: View {
    let totalSpent: Decimal
    let totalBudgeted: Decimal
    let budgetFraction: Double
    let topBudgets: [Budget]
    let spentAmount: (Budget) -> Decimal
    let spentFraction: (Budget) -> Double
    let categoryName: (UUID) -> String
    let categoryIcon: (UUID) -> String
    let categoryColorHex: (UUID) -> String

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(totalSpent.currencyFormatted())
                    .font(.title3.bold().monospacedDigit())
                Text("of \(totalBudgeted.currencyFormatted()) budgeted")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            GradientProgressBar(fraction: budgetFraction)

            ForEach(topBudgets) { budget in
                DashboardBudgetCategoryRow(
                    categoryName: categoryName(budget.categoryId),
                    categoryIcon: categoryIcon(budget.categoryId),
                    categoryColorHex: categoryColorHex(budget.categoryId),
                    spent: spentAmount(budget),
                    limit: budget.amount,
                    fraction: spentFraction(budget)
                )
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Budget Category Row

private struct DashboardBudgetCategoryRow: View {
    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    let spent: Decimal
    let limit: Decimal
    let fraction: Double

    var body: some View {
        HStack(spacing: 10) {
            CircularIcon(systemName: categoryIcon, color: Color(hex: categoryColorHex), size: 28)

            Text(categoryName)
                .font(.subheadline.weight(.medium))

            Spacer()

            Text("\(spent.currencyFormatted()) / \(limit.currencyFormatted())")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}
