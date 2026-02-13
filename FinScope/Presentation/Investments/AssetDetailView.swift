import SwiftUI

struct AssetDetailView: View {
    @Bindable var viewModel: AssetDetailViewModel

    var body: some View {
        List {
            if let asset = viewModel.asset {
                // Price Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.currentPrice.currencyFormatted())
                            .font(.largeTitle.bold().monospacedDigit())
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.priceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("\(viewModel.priceChange >= 0 ? "+" : "")\(viewModel.priceChange.percentageFormatted())")
                        }
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(viewModel.priceChange >= 0 ? .green : .red)

                        if !viewModel.priceHistory.isEmpty {
                            SparklineView(ticks: viewModel.priceHistory)
                                .frame(height: 120)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Info Section
                Section("Info") {
                    LabeledContent("Type", value: asset.type.displayName)
                    LabeledContent("Sector", value: asset.sector)
                    LabeledContent("Base Price", value: asset.basePrice.currencyFormatted())
                }

                // Position Section
                if let holding = viewModel.holding {
                    Section("Your Position") {
                        LabeledContent("Shares", value: "\(holding.quantity)")
                        LabeledContent("Avg Cost", value: holding.averageCostBasis.currencyFormatted())
                        LabeledContent("Market Value", value: viewModel.holdingValue.currencyFormatted())

                        HStack {
                            Text("Gain/Loss")
                            Spacer()
                            Text(viewModel.holdingGainLoss.currencyFormatted())
                                .foregroundStyle(viewModel.holdingGainLoss >= 0 ? .green : .red)
                        }
                    }
                }

                // Trade History
                if !viewModel.trades.isEmpty {
                    Section("Trade History") {
                        ForEach(viewModel.trades) { trade in
                            TradeRowView(trade: trade)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.asset?.ticker ?? "")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { viewModel.onBuy?() }) {
                        Label("Buy", systemImage: "plus.circle")
                    }
                    Button(action: { viewModel.onSell?() }) {
                        Label("Sell", systemImage: "minus.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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

extension AssetType {
    var displayName: String {
        switch self {
        case .stock: "Stock"
        case .bond: "Bond"
        case .etf: "ETF"
        }
    }
}
