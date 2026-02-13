import SwiftUI

struct WatchTabView: View {
    let portfolioRepository: PortfolioRepositoryProtocol
    let marketService: MarketSimulatorServiceProtocol

    var body: some View {
        TabView {
            WatchPortfolioView(
                portfolioRepository: portfolioRepository,
                marketService: marketService
            )
            .tabItem {
                Label("Portfolio", systemImage: "chart.pie")
            }

            WatchMarketView(
                marketService: marketService,
                portfolioRepository: portfolioRepository
            )
            .tabItem {
                Label("Market", systemImage: "chart.line.uptrend.xyaxis")
            }
        }
    }
}
