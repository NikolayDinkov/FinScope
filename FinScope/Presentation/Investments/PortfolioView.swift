import SwiftUI

struct PortfolioView: View {
    @Bindable var viewModel: PortfolioViewModel

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Portfolio Value")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.totalPortfolioValue.currencyFormatted())
                        .font(.largeTitle.bold().monospacedDigit())

                    HStack(spacing: 4) {
                        Image(systemName: viewModel.totalGainLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(viewModel.totalGainLoss.currencyFormatted()) (\(viewModel.totalGainLossPercent.percentageFormatted()))")
                    }
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(viewModel.totalGainLoss >= 0 ? .green : .red)

                    Divider()

                    HStack {
                        Text("Cash Available")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(viewModel.cashBalance.currencyFormatted())
                            .monospacedDigit()
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 4)
            }

            Section("Holdings") {
                if viewModel.holdings.isEmpty {
                    ContentUnavailableView(
                        "No Holdings",
                        systemImage: "chart.pie",
                        description: Text("Tap the market icon to browse assets and start trading.")
                    )
                } else {
                    ForEach(viewModel.holdings) { holding in
                        HoldingRowView(
                            holding: holding,
                            currentPrice: viewModel.currentPrices[holding.assetTicker] ?? holding.averageCostBasis
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.onSelectAsset?(holding.assetTicker)
                        }
                    }
                }
            }
        }
        .navigationTitle("Investments")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.onOpenMarket?() }) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                }
            }
        }
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
