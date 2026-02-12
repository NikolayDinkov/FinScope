import Foundation

protocol AccountRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Account]
    func fetchById(_ id: UUID) async throws -> Account?
    func create(_ account: Account) async throws
    func update(_ account: Account) async throws
    func delete(_ id: UUID) async throws
    func hasTransactions(_ accountId: UUID) async throws -> Bool
}
