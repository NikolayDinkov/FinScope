import Foundation

protocol AccountRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Account]
    func fetchByUser(_ userId: UUID) async throws -> [Account]
    func fetch(byId id: UUID) async throws -> Account?
    func save(_ account: Account) async throws
    func delete(_ account: Account) async throws
}
