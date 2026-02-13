import SwiftUI

struct InvestmentsCoordinatorView: View {
    @ObservedObject var coordinator: InvestmentsCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PortfolioView(viewModel: coordinator.portfolioViewModel)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .market:
                        MarketView(viewModel: coordinator.marketViewModel)
                    case .assetDetail(let ticker):
                        AssetDetailView(viewModel: coordinator.assetDetailViewModel(for: ticker))
                    default:
                        Text("Not implemented")
                    }
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .tradeForm(let ticker, let action):
                TradeFormView(viewModel: coordinator.makeTradeFormViewModel(ticker: ticker, action: action))
            }
        }
        .onAppear {
            // Market service is started globally in FinScopeApp for Watch connectivity
        }
    }
}
