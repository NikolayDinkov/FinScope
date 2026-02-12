import Foundation

protocol CategoryRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Category]
    func fetchByType(_ type: TransactionType) async throws -> [Category]
    func fetchById(_ id: UUID) async throws -> Category?
    func create(_ category: Category) async throws
    func update(_ category: Category) async throws
    func delete(_ id: UUID) async throws
    func seedDefaultsIfNeeded(defaults: [Category]) async throws
}
