import Foundation

protocol UserRepositoryProtocol: Sendable {
    func fetch(byId id: UUID) async throws -> User?
    func fetchAll() async throws -> [User]
    func save(_ user: User) async throws
    func delete(_ user: User) async throws
}
