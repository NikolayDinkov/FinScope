import SwiftUI
import Charts

struct InvestmentGrowthChart: View {
    let projections: [MonthlyProjection]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Investment Growth")
                .font(.headline)

            Chart(projections, id: \.month) { projection in
                LineMark(
                    x: .value("Month", projection.month),
                    y: .value("Balance", projection.balance.doubleValue)
                )
                .foregroundStyle(.green)

                AreaMark(
                    x: .value("Month", projection.month),
                    y: .value("Balance", projection.balance.doubleValue)
                )
                .foregroundStyle(.green.opacity(0.1))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
}
