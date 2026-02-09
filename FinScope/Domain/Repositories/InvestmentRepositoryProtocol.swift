import Foundation

protocol InvestmentRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Investment]
    func fetchByPortfolio(_ portfolioId: UUID) async throws -> [Investment]
    func fetch(byId id: UUID) async throws -> Investment?
    func save(_ investment: Investment) async throws
    func delete(_ investment: Investment) async throws
}
