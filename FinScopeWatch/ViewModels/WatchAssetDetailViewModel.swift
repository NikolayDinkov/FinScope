import Foundation
import Combine

@MainActor @Observable
final class WatchAssetDetailViewModel {
    var asset: MockAsset?
    var currentPrice: Decimal = 0
    var priceChange: Decimal = 0
    var priceHistory: [PriceTick] = []
    var holding: PortfolioHolding?
    var errorMessage: String?

    let ticker: String
    private let marketService: MarketSimulatorServiceProtocol
    private let portfolioRepository: PortfolioRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    var holdingValue: Decimal {
        guard let holding else { return 0 }
        return holding.quantity * currentPrice
    }

    var holdingGainLoss: Decimal {
        guard let holding else { return 0 }
        return (currentPrice - holding.averageCostBasis) * holding.quantity
    }

    init(
        ticker: String,
        marketService: MarketSimulatorServiceProtocol,
        portfolioRepository: PortfolioRepositoryProtocol
    ) {
        self.ticker = ticker
        self.marketService = marketService
        self.portfolioRepository = portfolioRepository

        marketService.priceUpdates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self else { return }
                guard let price = update.prices[ticker] else { return }
                if let change = update.changes[ticker] {
                    self.currentPrice = price
                    self.priceChange = change
                    self.priceHistory = marketService.priceHistory(for: ticker, limit: 30)
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .dataDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.loadPortfolioData() }
            }
            .store(in: &cancellables)
    }

    func load() async {
        let assets = marketService.allAssets()
        asset = assets.first { $0.ticker == ticker }
        let price = marketService.currentPrice(for: ticker) ?? 0
        currentPrice = price
        priceHistory = marketService.priceHistory(for: ticker, limit: 30)
        await loadPortfolioData()
    }

    private func loadPortfolioData() async {
        do {
            holding = try await portfolioRepository.fetchHolding(byTicker: ticker)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
