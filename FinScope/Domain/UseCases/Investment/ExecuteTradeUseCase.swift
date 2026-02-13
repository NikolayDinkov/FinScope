import Foundation

enum TradeError: Error, Equatable {
    case insufficientCash
    case insufficientShares
    case assetNotFound
    case invalidQuantity
}

struct ExecuteTradeUseCase: Sendable {
    private let repository: PortfolioRepositoryProtocol
    private let marketService: MarketSimulatorServiceProtocol

    init(
        repository: PortfolioRepositoryProtocol,
        marketService: MarketSimulatorServiceProtocol
    ) {
        self.repository = repository
        self.marketService = marketService
    }

    func execute(
        ticker: String,
        action: TradeAction,
        quantity: Decimal,
        initialCapital: Decimal
    ) async throws {
        guard quantity > 0 else {
            throw TradeError.invalidQuantity
        }

        guard let currentPrice = marketService.currentPrice(for: ticker) else {
            throw TradeError.assetNotFound
        }

        let totalCost = quantity * currentPrice

        switch action {
        case .buy:
            let cashAvailable = try await calculateCashBalance(initialCapital: initialCapital)
            guard cashAvailable >= totalCost else {
                throw TradeError.insufficientCash
            }

            let trade = Trade(
                assetTicker: ticker,
                action: .buy,
                quantity: quantity,
                pricePerUnit: currentPrice
            )
            try await repository.createTrade(trade)

            if var holding = try await repository.fetchHolding(byTicker: ticker) {
                let totalShares = holding.quantity + quantity
                let totalCostBasis = (holding.averageCostBasis * holding.quantity) + totalCost
                holding.averageCostBasis = (totalCostBasis / totalShares).rounded(scale: 2)
                holding.quantity = totalShares
                holding.updatedAt = Date()
                try await repository.updateHolding(holding)
            } else {
                let holding = PortfolioHolding(
                    assetTicker: ticker,
                    quantity: quantity,
                    averageCostBasis: currentPrice
                )
                try await repository.createHolding(holding)
            }

        case .sell:
            guard let holding = try await repository.fetchHolding(byTicker: ticker),
                  holding.quantity >= quantity else {
                throw TradeError.insufficientShares
            }

            let trade = Trade(
                assetTicker: ticker,
                action: .sell,
                quantity: quantity,
                pricePerUnit: currentPrice
            )
            try await repository.createTrade(trade)

            var updatedHolding = holding
            updatedHolding.quantity -= quantity
            updatedHolding.updatedAt = Date()

            if updatedHolding.quantity == 0 {
                try await repository.deleteHolding(updatedHolding)
            } else {
                try await repository.updateHolding(updatedHolding)
            }
        }
    }

    private func calculateCashBalance(initialCapital: Decimal) async throws -> Decimal {
        let trades = try await repository.fetchAllTrades()
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
