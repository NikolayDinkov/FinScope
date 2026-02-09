import SwiftUI
import Charts

struct CashFlowTimelineView: View {
    let projections: [ForecastMonth]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Cash Flow")
                .font(.headline)

            Chart(projections, id: \.month) { month in
                BarMark(
                    x: .value("Month", month.month),
                    y: .value("Income", month.income.doubleValue)
                )
                .foregroundStyle(.green)

                BarMark(
                    x: .value("Month", month.month),
                    y: .value("Expenses", -month.expenses.doubleValue)
                )
                .foregroundStyle(.red)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
}
