import SwiftUI

struct WatchPortfolioView: View {
    let portfolioRepository: PortfolioRepositoryProtocol
    let marketService: MarketSimulatorServiceProtocol

    @State private var viewModel: WatchPortfolioViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    List {
                        Section {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.totalPortfolioValue.currencyFormatted())
                                    .font(.headline.monospacedDigit())

                                HStack(spacing: 2) {
                                    Image(systemName: viewModel.totalGainLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                                    Text(viewModel.totalGainLossPercent.percentageFormatted())
                                }
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(viewModel.totalGainLoss >= 0 ? .green : .red)
                            }
                        }

                        Section {
                            HStack {
                                Text("Cash")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(viewModel.cashBalance.currencyFormatted())
                                    .font(.caption.monospacedDigit())
                            }
                        }

                        if viewModel.holdings.isEmpty {
                            Section {
                                Text("No holdings yet")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Section("Holdings") {
                                ForEach(viewModel.holdings) { holding in
                                    NavigationLink(value: holding.assetTicker) {
                                        WatchHoldingRow(
                                            holding: holding,
                                            currentPrice: viewModel.currentPrices[holding.assetTicker] ?? holding.averageCostBasis
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .navigationDestination(for: String.self) { ticker in
                        WatchAssetDetailView(
                            ticker: ticker,
                            marketService: marketService,
                            portfolioRepository: portfolioRepository
                        )
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Portfolio")
            .task {
                let vm = WatchPortfolioViewModel(
                    fetchPortfolioUseCase: FetchPortfolioUseCase(repository: portfolioRepository),
                    fetchTradeHistoryUseCase: FetchTradeHistoryUseCase(repository: portfolioRepository),
                    marketService: marketService
                )
                viewModel = vm
                await vm.load()
            }
        }
    }
}
