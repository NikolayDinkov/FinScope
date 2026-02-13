import Foundation

struct FetchTradeHistoryUseCase: Sendable {
    private let repository: PortfolioRepositoryProtocol

    init(repository: PortfolioRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Trade] {
        try await repository.fetchAllTrades()
    }

    func execute(forTicker ticker: String) async throws -> [Trade] {
        try await repository.fetchTrades(forTicker: ticker)
    }
}
