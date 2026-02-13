import SwiftUI

struct WatchAssetDetailView: View {
    let ticker: String
    let marketService: MarketSimulatorServiceProtocol
    let portfolioRepository: PortfolioRepositoryProtocol

    @State private var viewModel: WatchAssetDetailViewModel?
    @State private var showTradeSheet = false
    @State private var tradeAction: TradeAction = .buy

    var body: some View {
        Group {
            if let viewModel {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.currentPrice.currencyFormatted())
                                .font(.headline.monospacedDigit())

                            HStack(spacing: 2) {
                                Image(systemName: viewModel.priceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                                Text("\(viewModel.priceChange >= 0 ? "+" : "")\(viewModel.priceChange.percentageFormatted())")
                            }
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(viewModel.priceChange >= 0 ? .green : .red)

                            if !viewModel.priceHistory.isEmpty {
                                SparklineView(ticks: viewModel.priceHistory)
                                    .frame(height: 50)
                            }
                        }
                    }

                    if let holding = viewModel.holding {
                        Section("Position") {
                            LabeledContent("Shares") {
                                Text("\(holding.quantity)")
                                    .font(.caption.monospacedDigit())
                            }
                            .font(.caption)
                            LabeledContent("Value") {
                                Text(viewModel.holdingValue.currencyFormatted())
                                    .font(.caption.monospacedDigit())
                            }
                            .font(.caption)
                            LabeledContent("P&L") {
                                Text(viewModel.holdingGainLoss.currencyFormatted())
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(viewModel.holdingGainLoss >= 0 ? .green : .red)
                            }
                            .font(.caption)
                        }
                    }

                    Section {
                        Button {
                            tradeAction = .buy
                            showTradeSheet = true
                        } label: {
                            Label("Buy", systemImage: "plus.circle")
                        }
                        .tint(.green)

                        Button {
                            tradeAction = .sell
                            showTradeSheet = true
                        } label: {
                            Label("Sell", systemImage: "minus.circle")
                        }
                        .tint(.red)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(ticker)
        .sheet(isPresented: $showTradeSheet) {
            WatchTradeFormView(
                ticker: ticker,
                action: tradeAction,
                marketService: marketService,
                portfolioRepository: portfolioRepository
            )
        }
        .task {
            let vm = WatchAssetDetailViewModel(
                ticker: ticker,
                marketService: marketService,
                portfolioRepository: portfolioRepository
            )
            viewModel = vm
            await vm.load()
        }
    }
}
