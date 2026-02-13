import SwiftUI

struct ForecastView: View {
    @Bindable var viewModel: ForecastViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: FinScopeTheme.sectionSpacing) {
                // Horizon Picker + Balance Card
                VStack(spacing: 16) {
                    PillSegmentControl(
                        options: ForecastHorizon.allCases,
                        selected: $viewModel.selectedHorizon,
                        label: { "\($0.rawValue)M" }
                    )
                    .onChange(of: viewModel.selectedHorizon) { _, newValue in
                        viewModel.changeHorizon(to: newValue)
                    }

                    VStack(spacing: 6) {
                        Text("Current Balance")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(viewModel.currentBalance.currencyFormatted())
                            .font(.system(size: 32, weight: .bold, design: .rounded).monospacedDigit())

                        ChangeIndicator(
                            value: viewModel.balanceChange,
                            formatted: viewModel.projectedEndBalance.currencyFormatted(),
                            font: .headline.monospacedDigit(),
                            showBackground: true
                        )

                        Text("projected in \(viewModel.selectedHorizon.rawValue) months")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Balance projection sparkline
                    if !viewModel.forecasts.isEmpty {
                        let forecastTicks = viewModel.forecasts.enumerated().map { index, forecast in
                            PriceTick(
                                ticker: "forecast",
                                price: forecast.projectedBalance,
                                timestamp: forecast.month
                            )
                        }
                        SparklineView(
                            ticks: forecastTicks,
                            lineColor: viewModel.balanceChange >= 0 ? .green : .red
                        )
                        .frame(height: 80)
                    }
                }
                .cardStyle()

                // Monthly Breakdown
                if !viewModel.forecasts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Monthly Breakdown")

                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.forecasts.enumerated()), id: \.element.id) { index, forecast in
                                ForecastMonthRowView(forecast: forecast)
                                if index < viewModel.forecasts.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                    .cardStyle()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, FinScopeTheme.sectionSpacing)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .overlay {
            if viewModel.forecasts.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "No Forecast Data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Add accounts and recurring transactions to see projections.")
                )
            }
        }
        .navigationTitle("Forecast")
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
