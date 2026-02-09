import SwiftUI
import Charts

struct ExpenseBreakdownChart: View {
    let categories: [(name: String, amount: Decimal)]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Expense Breakdown")
                .font(.headline)

            Chart(categories, id: \.name) { category in
                SectorMark(
                    angle: .value("Amount", category.amount.doubleValue),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Category", category.name))
            }
        }
    }
}
