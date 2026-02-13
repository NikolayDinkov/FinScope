import SwiftUI

struct ForecastView: View {
    @Bindable var viewModel: ForecastViewModel

    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Picker("Horizon", selection: $viewModel.selectedHorizon) {
                        Text("3M").tag(ForecastHorizon.threeMonths)
                        Text("6M").tag(ForecastHorizon.sixMonths)
                        Text("12M").tag(ForecastHorizon.twelveMonths)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedHorizon) { _, newValue in
                        viewModel.changeHorizon(to: newValue)
                    }

                    VStack(spacing: 4) {
                        Text("Current Balance")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(viewModel.currentBalance.currencyFormatted())
                            .font(.title2.bold().monospacedDigit())

                        HStack(spacing: 4) {
                            Image(systemName: viewModel.balanceChange >= 0
                                  ? "arrow.up.right" : "arrow.down.right")
                            Text(viewModel.projectedEndBalance.currencyFormatted())
                        }
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(viewModel.balanceChange >= 0 ? .green : .red)

                        Text("projected in \(viewModel.selectedHorizon.rawValue) months")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            if !viewModel.forecasts.isEmpty {
                Section("Monthly Breakdown") {
                    ForEach(viewModel.forecasts) { forecast in
                        ForecastMonthRowView(forecast: forecast)
                    }
                }
            }
        }
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
