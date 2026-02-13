import Testing
import Foundation
@testable import FinScope

struct ExecuteTradeUseCaseTests {
    @Test func testBuyCreatesHoldingAndTrade() async throws {
        let repo = MockPortfolioRepository()
        let market = MockMarketSimulatorService()
        market.prices["AAPL"] = 150

        let useCase = ExecuteTradeUseCase(repository: repo, marketService: market)
        try await useCase.execute(ticker: "AAPL", action: .buy, quantity: 10, initialCapital: 100_000)

        #expect(repo.holdings.count == 1)
        #expect(repo.holdings[0].assetTicker == "AAPL")
        #expect(repo.holdings[0].quantity == 10)
        #expect(repo.holdings[0].averageCostBasis == 150)
        #expect(repo.trades.count == 1)
        #expect(repo.trades[0].action == .buy)
        #expect(repo.trades[0].totalAmount == 1500)
    }

    @Test func testBuyUpdatesExistingHolding() async throws {
        let repo = MockPortfolioRepository()
        let market = MockMarketSimulatorService()
        market.prices["AAPL"] = 200

        let existing = PortfolioHolding(assetTicker: "AAPL", quantity: 10, averageCostBasis: 150)
        repo.holdings = [existing]

        let useCase = ExecuteTradeUseCase(repository: repo, marketService: market)
        try await useCase.execute(ticker: "AAPL", action: .buy, quantity: 10, initialCapital: 100_000)

        #expect(repo.holdings.count == 1)
        #expect(repo.holdings[0].quantity == 20)
        // Weighted avg: (150*10 + 200*10) / 20 = 175
        #expect(repo.holdings[0].averageCostBasis == 175)
    }

    @Test func testBuyInsufficientCashThrows() async throws {
        let repo = MockPortfolioRepository()
        let market = MockMarketSimulatorService()
        market.prices["AAPL"] = 150

        let useCase = ExecuteTradeUseCase(repository: repo, marketService: market)
        await #expect(throws: TradeError.insufficientCash) {
            try await useCase.execute(ticker: "AAPL", action: .buy, quantity: 1000, initialCapital: 100_000)
        }
    }

    @Test func testSellReducesHolding() async throws {
        let repo = MockPortfolioRepository()
        let market = MockMarketSimulatorService()
        market.prices["AAPL"] = 200

        let existing = PortfolioHolding(assetTicker: "AAPL", quantity: 10, averageCostBasis: 150)
        repo.holdings = [existing]

        let useCase = ExecuteTradeUseCase(repository: repo, marketService: market)
        try await useCase.execute(ticker: "AAPL", action: .sell, quantity: 5, initialCapital: 100_000)

        #expect(repo.holdings.count == 1)
        #expect(repo.holdings[0].quantity == 5)
        #expect(repo.trades.count == 1)
        #expect(repo.trades[0].action == .sell)
    }

    @Test func testSellAllDeletesHolding() async throws {
        let repo = MockPortfolioRepository()
        let market = MockMarketSimulatorService()
        market.prices["AAPL"] = 200

        let existing = PortfolioHolding(assetTicker: "AAPL", quantity: 10, averageCostBasis: 150)
        repo.holdings = [existing]

        let useCase = ExecuteTradeUseCase(repository: repo, marketService: market)
        try await useCase.execute(ticker: "AAPL", action: .sell, quantity: 10, initialCapital: 100_000)

        #expect(repo.holdings.isEmpty)
    }

    @Test func testSellInsufficientSharesThrows() async throws {
        let repo = MockPortfolioRepository()
        let market = MockMarketSimulatorService()
        market.prices["AAPL"] = 200

        let existing = PortfolioHolding(assetTicker: "AAPL", quantity: 5, averageCostBasis: 150)
        repo.holdings = [existing]

        let useCase = ExecuteTradeUseCase(repository: repo, marketService: market)
        await #expect(throws: TradeError.insufficientShares) {
            try await useCase.execute(ticker: "AAPL", action: .sell, quantity: 10, initialCapital: 100_000)
        }
    }

    @Test func testAssetNotFoundThrows() async throws {
        let repo = MockPortfolioRepository()
        let market = MockMarketSimulatorService()

        let useCase = ExecuteTradeUseCase(repository: repo, marketService: market)
        await #expect(throws: TradeError.assetNotFound) {
            try await useCase.execute(ticker: "UNKNOWN", action: .buy, quantity: 1, initialCapital: 100_000)
        }
    }

    @Test func testInvalidQuantityThrows() async throws {
        let repo = MockPortfolioRepository()
        let market = MockMarketSimulatorService()
        market.prices["AAPL"] = 150

        let useCase = ExecuteTradeUseCase(repository: repo, marketService: market)
        await #expect(throws: TradeError.invalidQuantity) {
            try await useCase.execute(ticker: "AAPL", action: .buy, quantity: 0, initialCapital: 100_000)
        }
    }
}
