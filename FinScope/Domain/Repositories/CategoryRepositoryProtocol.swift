import Foundation

protocol CategoryRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Category]
    func fetchByType(_ type: TransactionType) async throws -> [Category]
    func fetch(byId id: UUID) async throws -> Category?
    func save(_ category: Category) async throws
    func delete(_ category: Category) async throws
}
