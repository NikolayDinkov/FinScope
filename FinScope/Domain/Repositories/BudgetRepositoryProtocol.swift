import Foundation

protocol BudgetRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Budget]
    func fetchByUser(_ userId: UUID) async throws -> [Budget]
    func fetch(byId id: UUID) async throws -> Budget?
    func save(_ budget: Budget) async throws
    func delete(_ budget: Budget) async throws
}
