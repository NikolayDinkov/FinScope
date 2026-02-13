import Foundation

struct FetchPortfolioUseCase: Sendable {
    private let repository: PortfolioRepositoryProtocol

    init(repository: PortfolioRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [PortfolioHolding] {
        try await repository.fetchAllHoldings()
    }
}
