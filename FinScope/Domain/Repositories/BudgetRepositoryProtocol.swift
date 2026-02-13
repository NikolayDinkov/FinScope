import Foundation

protocol BudgetRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Budget]
    func fetchById(_ id: UUID) async throws -> Budget?
    func create(_ budget: Budget) async throws
    func update(_ budget: Budget) async throws
    func delete(_ id: UUID) async throws
}
