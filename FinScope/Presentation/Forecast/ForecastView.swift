import SwiftUI
import Charts

struct ForecastView: View {
    let viewModel: ForecastViewModel
    let coordinator: ForecastCoordinator

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Controls
                VStack(spacing: 12) {
                    Stepper("Projection: \(viewModel.projectionMonths) months",
                            value: Bindable(viewModel).projectionMonths,
                            in: 6...120,
                            step: 6)

                    Button {
                        Task { await viewModel.generate(userId: UUID()) }
                    } label: {
                        if viewModel.isGenerating {
                            ProgressView()
                        } else {
                            Label("Generate Forecast", systemImage: "wand.and.stars")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isGenerating)
                }
                .padding()

                // Current forecast chart
                if let forecast = viewModel.currentForecast {
                    NetWorthChartView(projections: forecast.monthlyProjections)
                        .frame(height: 250)
                        .padding()

                    CashFlowTimelineView(projections: forecast.monthlyProjections)
                        .frame(height: 200)
                        .padding()
                }

                // Compare button
                if viewModel.forecasts.count >= 2 {
                    Button("Compare Scenarios") {
                        coordinator.router.push(.comparison(viewModel.forecasts))
                    }
                    .buttonStyle(.bordered)
                }

                // Saved forecasts
                if !viewModel.forecasts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Saved Forecasts")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(viewModel.forecasts) { forecast in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(forecast.name)
                                        .font(.body)
                                    Text("\(forecast.projectionMonths) months")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(DateFormatter.financeDate.string(from: forecast.createdAt))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
        }
        .navigationTitle("Forecast")
        .task {
            await viewModel.load()
        }
    }
}
