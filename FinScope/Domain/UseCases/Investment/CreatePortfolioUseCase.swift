import Foundation

struct CreatePortfolioUseCase: Sendable {
    private let repository: any PortfolioRepositoryProtocol

    init(repository: any PortfolioRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, userId: UUID) async throws -> Portfolio {
        guard !name.trimmed.isEmpty else {
            throw PortfolioError.invalidName
        }

        let portfolio = Portfolio(name: name.trimmed, userId: userId)
        try await repository.save(portfolio)
        return portfolio
    }
}

enum PortfolioError: Error, LocalizedError {
    case invalidName
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidName: "Portfolio name cannot be empty"
        case .notFound: "Portfolio not found"
        }
    }
}
