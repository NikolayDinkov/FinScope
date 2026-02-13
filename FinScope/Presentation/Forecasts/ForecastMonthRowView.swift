import SwiftUI

struct ForecastMonthRowView: View {
    let forecast: MonthlyForecast

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Self.monthFormatter.string(from: forecast.month))
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Income")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(forecast.projectedIncome.currencyFormatted())
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.green)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Expenses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(forecast.projectedExpenses.currencyFormatted())
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.red)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Net")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(forecast.netCashFlow.currencyFormatted())
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(forecast.netCashFlow >= 0 ? .green : .red)
                }
            }

            HStack {
                Text("Ending Balance")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(forecast.projectedBalance.currencyFormatted())
                    .font(.subheadline.bold().monospacedDigit())
            }
        }
        .padding(.vertical, 4)
    }
}
