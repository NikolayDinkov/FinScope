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

            BudgetDashboardProgressBar(fraction: budgetFraction)

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
            Image(systemName: categoryIcon)
                .foregroundStyle(Color(hex: categoryColorHex))
                .frame(width: 24, height: 24)
                .background(Color(hex: categoryColorHex).opacity(0.15))
                .clipShape(Circle())

            Text(categoryName)
                .font(.subheadline)

            Spacer()

            Text("\(spent.currencyFormatted()) / \(limit.currencyFormatted())")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Progress Bar

private struct BudgetDashboardProgressBar: View {
    let fraction: Double

    private var barColor: Color {
        switch fraction {
        case ..<0.75: .green
        case ..<1.0: .yellow
        default: .red
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))

                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(width: min(geometry.size.width * min(fraction, 1.0), geometry.size.width))
            }
        }
        .frame(height: 8)
    }
}
