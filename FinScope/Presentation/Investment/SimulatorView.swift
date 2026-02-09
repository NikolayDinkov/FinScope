import SwiftUI
import Charts

struct SimulatorView: View {
    let viewModel: SimulatorViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Strategy picker
                Picker("Strategy", selection: Bindable(viewModel).selectedStrategy) {
                    ForEach(StrategyType.allCases, id: \.self) { strategy in
                        Text(strategy.rawValue).tag(strategy)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Duration slider
                VStack(alignment: .leading) {
                    Text("Duration: \(viewModel.simulationMonths / 12) years")
                        .font(.subheadline)
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.simulationMonths) },
                            set: { viewModel.simulationMonths = Int($0) }
                        ),
                        in: 12...360,
                        step: 12
                    )
                }
                .padding(.horizontal)

                Button("Run Simulation") {
                    viewModel.simulate()
                }
                .buttonStyle(.borderedProminent)

                // Results
                if !viewModel.projections.isEmpty {
                    VStack(spacing: 16) {
                        LabeledContent("Final Balance",
                                       value: viewModel.projections.last?.balance.currencyFormatted ?? "-")
                        LabeledContent("Total Return",
                                       value: viewModel.totalReturn.currencyFormatted)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Growth chart
                    InvestmentGrowthChart(projections: viewModel.projections)
                        .frame(height: 250)
                        .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
        }
        .navigationTitle("Simulator")
    }
}
