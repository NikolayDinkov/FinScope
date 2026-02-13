import Testing
import Foundation
@testable import FinScope

struct FetchPortfolioUseCaseTests {
    @Test func testFetchReturnsAllHoldings() async throws {
        let repo = MockPortfolioRepository()
        repo.holdings = [
            PortfolioHolding(assetTicker: "AAPL", quantity: 10, averageCostBasis: 150),
            PortfolioHolding(assetTicker: "GOOG", quantity: 5, averageCostBasis: 200),
        ]

        let useCase = FetchPortfolioUseCase(repository: repo)
        let result = try await useCase.execute()

        #expect(result.count == 2)
        #expect(result[0].assetTicker == "AAPL")
        #expect(result[1].assetTicker == "GOOG")
    }

    @Test func testFetchEmptyReturnsEmpty() async throws {
        let repo = MockPortfolioRepository()
        let useCase = FetchPortfolioUseCase(repository: repo)
        let result = try await useCase.execute()
        #expect(result.isEmpty)
    }

    @Test func testFetchThrowsOnError() async throws {
        let repo = MockPortfolioRepository()
        repo.shouldThrow = true
        let useCase = FetchPortfolioUseCase(repository: repo)
        await #expect(throws: MockError.self) {
            try await useCase.execute()
        }
    }
}
