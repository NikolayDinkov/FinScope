import Foundation
import Combine

@MainActor @Observable
final class TradeFormViewModel {
    var ticker: String
    var action: TradeAction
    var quantityText: String = ""
    var currentPrice: Decimal = 0
    var availableCash: Decimal = 0
    var availableShares: Decimal = 0
    var errorMessage: String?
    var didComplete = false

    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?

    private let executeTradeUseCase: ExecuteTradeUseCase
    private let marketService: MarketSimulatorServiceProtocol
    private let portfolioRepository: PortfolioRepositoryProtocol
    private let initialCapital: Decimal
    private var cancellables = Set<AnyCancellable>()

    var quantity: Decimal {
        Decimal(string: quantityText) ?? 0
    }

    var isValid: Bool {
        quantity > 0
    }

    var totalCost: Decimal {
        quantity * currentPrice
    }

    init(
        ticker: String,
        action: TradeAction,
        executeTradeUseCase: ExecuteTradeUseCase,
        marketService: MarketSimulatorServiceProtocol,
        portfolioRepository: PortfolioRepositoryProtocol,
        initialCapital: Decimal = 100_000
    ) {
        self.ticker = ticker
        self.action = action
        self.executeTradeUseCase = executeTradeUseCase
        self.marketService = marketService
        self.portfolioRepository = portfolioRepository
        self.initialCapital = initialCapital

        marketService.priceUpdates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self else { return }
                if let price = update.prices[ticker] {
                    self.currentPrice = price
                }
            }
            .store(in: &cancellables)
    }

    func load() async {
        currentPrice = marketService.currentPrice(for: ticker) ?? 0
        do {
            if let holding = try await portfolioRepository.fetchHolding(byTicker: ticker) {
                availableShares = holding.quantity
            }
            let trades = try await portfolioRepository.fetchAllTrades()
            var cash = initialCapital
            for trade in trades {
                switch trade.action {
                case .buy: cash -= trade.totalAmount
                case .sell: cash += trade.totalAmount
                }
            }
            availableCash = cash
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func executeTrade() async {
        errorMessage = nil
        do {
            try await executeTradeUseCase.execute(
                ticker: ticker,
                action: action,
                quantity: quantity,
                initialCapital: initialCapital
            )
            didComplete = true
            onSave?()
        } catch let error as TradeError {
            switch error {
            case .insufficientCash:
                errorMessage = "Insufficient cash to complete this purchase."
            case .insufficientShares:
                errorMessage = "You don't have enough shares to sell."
            case .assetNotFound:
                errorMessage = "Asset not found."
            case .invalidQuantity:
                errorMessage = "Please enter a valid quantity."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
