import Foundation
import Combine

@MainActor @Observable
final class PortfolioViewModel {
    var holdings: [PortfolioHolding] = []
    var currentPrices: [String: Decimal] = [:]
    var cashBalance: Decimal = 0
    var errorMessage: String?
    var isLoading = false

    var onOpenMarket: (() -> Void)?
    var onSelectAsset: ((String) -> Void)?

    let initialCapital: Decimal = 100_000

    private let fetchPortfolioUseCase: FetchPortfolioUseCase
    private let fetchTradeHistoryUseCase: FetchTradeHistoryUseCase
    private let marketService: MarketSimulatorServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    var totalPortfolioValue: Decimal {
        let holdingsValue = holdings.reduce(Decimal.zero) { sum, holding in
            let price = currentPrices[holding.assetTicker] ?? holding.averageCostBasis
            return sum + holding.quantity * price
        }
        return cashBalance + holdingsValue
    }

    var totalGainLoss: Decimal {
        totalPortfolioValue - initialCapital
    }

    var totalGainLossPercent: Decimal {
        guard initialCapital != 0 else { return 0 }
        return ((totalPortfolioValue - initialCapital) / initialCapital * 100).rounded(scale: 2)
    }

    init(
        fetchPortfolioUseCase: FetchPortfolioUseCase,
        fetchTradeHistoryUseCase: FetchTradeHistoryUseCase,
        marketService: MarketSimulatorServiceProtocol
    ) {
        self.fetchPortfolioUseCase = fetchPortfolioUseCase
        self.fetchTradeHistoryUseCase = fetchTradeHistoryUseCase
        self.marketService = marketService

        marketService.priceUpdates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.currentPrices = update.prices
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .dataDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.load() }
            }
            .store(in: &cancellables)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            holdings = try await fetchPortfolioUseCase.execute()
            let trades = try await fetchTradeHistoryUseCase.execute()
            cashBalance = calculateCash(from: trades)
            currentPrices = marketService.currentPrices()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func startMarket() {
        marketService.start()
    }

    func stopMarket() {
        marketService.stop()
    }

    private func calculateCash(from trades: [Trade]) -> Decimal {
        var cash = initialCapital
        for trade in trades {
            switch trade.action {
            case .buy:
                cash -= trade.totalAmount
            case .sell:
                cash += trade.totalAmount
            }
        }
        return cash
    }
}
