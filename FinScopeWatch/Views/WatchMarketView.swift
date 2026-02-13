import SwiftUI

struct WatchMarketView: View {
    let marketService: MarketSimulatorServiceProtocol
    let portfolioRepository: PortfolioRepositoryProtocol

    @State private var viewModel: WatchMarketViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    List {
                        Picker("Filter", selection: Binding(
                            get: { viewModel.selectedFilter },
                            set: { viewModel.selectedFilter = $0 }
                        )) {
                            ForEach(AssetTypeFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }

                        ForEach(viewModel.filteredAssets) { asset in
                            NavigationLink(value: asset.ticker) {
                                WatchAssetRow(
                                    asset: asset,
                                    price: viewModel.currentPrices[asset.ticker] ?? asset.basePrice,
                                    change: viewModel.priceChanges[asset.ticker] ?? 0
                                )
                            }
                        }
                    }
                    .searchable(text: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.searchText = $0 }
                    ), prompt: "Search ticker")
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
            .navigationTitle("Market")
            .task {
                let vm = WatchMarketViewModel(marketService: marketService)
                viewModel = vm
                vm.load()
            }
        }
    }
}
