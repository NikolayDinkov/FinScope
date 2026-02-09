import SwiftUI
import Charts

struct ScenarioComparisonView: View {
    let forecasts: [Forecast]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if forecasts.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.xaxis",
                        title: "No Scenarios",
                        message: "Generate at least two forecasts to compare"
                    )
                } else {
                    Chart {
                        ForEach(forecasts) { forecast in
                            ForEach(forecast.monthlyProjections, id: \.month) { month in
                                LineMark(
                                    x: .value("Month", month.month),
                                    y: .value("Net Worth", month.netWorth.doubleValue)
                                )
                                .foregroundStyle(by: .value("Scenario", forecast.name))
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding()

                    // Summary table
                    ForEach(forecasts) { forecast in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(forecast.name)
                                .font(.headline)

                            if let last = forecast.monthlyProjections.last {
                                LabeledContent("Final Net Worth", value: last.netWorth.currencyFormatted)
                                LabeledContent("Final Savings", value: last.savings.currencyFormatted)
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Compare Scenarios")
    }
}
