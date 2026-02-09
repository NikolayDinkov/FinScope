import SwiftUI
import Charts

struct NetWorthChartView: View {
    let projections: [ForecastMonth]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Net Worth Projection")
                .font(.headline)

            Chart(projections, id: \.month) { month in
                AreaMark(
                    x: .value("Month", month.month),
                    y: .value("Net Worth", month.netWorth.doubleValue)
                )
                .foregroundStyle(.blue.opacity(0.2))

                LineMark(
                    x: .value("Month", month.month),
                    y: .value("Net Worth", month.netWorth.doubleValue)
                )
                .foregroundStyle(.blue)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
}
