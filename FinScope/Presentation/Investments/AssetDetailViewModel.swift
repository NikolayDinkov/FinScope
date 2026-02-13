import Foundation
import Combine

@MainActor @Observable
final class AssetDetailViewModel {
    var asset: MockAsset?
    var currentPrice: Decimal = 0
    var priceChange: Decimal = 0
    var priceHistory: [PriceTick] = []
    var holding: PortfolioHolding?
    var trades: [Trade] = []
    var errorMessage: String?

    var onBuy: (() -> Void)?
    var onSell: (() -> Void)?

    private let ticker: String
    private let marketService: MarketSimulatorServiceProtocol
    private let fetchPortfolioUseCase: FetchPortfolioUseCase
    private let fetchTradeHistoryUseCase: FetchTradeHistoryUseCase
    private let portfolioRepository: PortfolioRepositoryProtocol
    private var previousPrice: Decimal = 0
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
        fetchPortfolioUseCase: FetchPortfolioUseCase,
        fetchTradeHistoryUseCase: FetchTradeHistoryUseCase,
        portfolioRepository: PortfolioRepositoryProtocol
    ) {
        self.ticker = ticker
        self.marketService = marketService
        self.fetchPortfolioUseCase = fetchPortfolioUseCase
        self.fetchTradeHistoryUseCase = fetchTradeHistoryUseCase
        self.portfolioRepository = portfolioRepository

        marketService.priceUpdates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self else { return }
                guard let price = update.prices[ticker] else { return }
                if let change = update.changes[ticker] {
                    self.previousPrice = self.currentPrice
                    self.currentPrice = price
                    self.priceChange = change
                    self.priceHistory = marketService.priceHistory(for: ticker, limit: 60)
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
        previousPrice = price
        priceHistory = marketService.priceHistory(for: ticker, limit: 60)
        await loadPortfolioData()
    }

    private func loadPortfolioData() async {
        do {
            holding = try await portfolioRepository.fetchHolding(byTicker: ticker)
            trades = try await fetchTradeHistoryUseCase.execute(forTicker: ticker)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
