import Foundation

protocol TransactionRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Transaction]
    func fetchByAccount(_ accountId: UUID) async throws -> [Transaction]
    func fetchByCategory(_ categoryId: UUID) async throws -> [Transaction]
    func fetchInDateRange(from: Date, to: Date) async throws -> [Transaction]
    func fetch(byId id: UUID) async throws -> Transaction?
    func save(_ transaction: Transaction) async throws
    func saveAll(_ transactions: [Transaction]) async throws
    func delete(_ transaction: Transaction) async throws
    func countByAccount(_ accountId: UUID) async throws -> Int
}
