import Foundation

protocol PortfolioRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Portfolio]
    func fetchByUser(_ userId: UUID) async throws -> [Portfolio]
    func fetch(byId id: UUID) async throws -> Portfolio?
    func save(_ portfolio: Portfolio) async throws
    func delete(_ portfolio: Portfolio) async throws
}
