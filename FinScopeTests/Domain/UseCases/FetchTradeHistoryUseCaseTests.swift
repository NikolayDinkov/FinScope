import Testing
import Foundation
@testable import FinScope

struct FetchTradeHistoryUseCaseTests {
    @Test func testFetchAllTrades() async throws {
        let repo = MockPortfolioRepository()
        repo.trades = [
            Trade(assetTicker: "AAPL", action: .buy, quantity: 10, pricePerUnit: 150),
            Trade(assetTicker: "GOOG", action: .buy, quantity: 5, pricePerUnit: 200),
        ]

        let useCase = FetchTradeHistoryUseCase(repository: repo)
        let result = try await useCase.execute()

        #expect(result.count == 2)
    }

    @Test func testFetchTradesForTicker() async throws {
        let repo = MockPortfolioRepository()
        repo.trades = [
            Trade(assetTicker: "AAPL", action: .buy, quantity: 10, pricePerUnit: 150),
            Trade(assetTicker: "GOOG", action: .buy, quantity: 5, pricePerUnit: 200),
            Trade(assetTicker: "AAPL", action: .sell, quantity: 3, pricePerUnit: 160),
        ]

        let useCase = FetchTradeHistoryUseCase(repository: repo)
        let result = try await useCase.execute(forTicker: "AAPL")

        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.assetTicker == "AAPL" })
    }

    @Test func testFetchEmptyReturnsEmpty() async throws {
        let repo = MockPortfolioRepository()
        let useCase = FetchTradeHistoryUseCase(repository: repo)
        let result = try await useCase.execute()
        #expect(result.isEmpty)
    }
}
