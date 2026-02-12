import Foundation

protocol TransactionRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Transaction]
    func fetchAll(for accountId: UUID) async throws -> [Transaction]
    func fetchById(_ id: UUID) async throws -> Transaction?
    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [Transaction]
    func create(_ transaction: Transaction) async throws
    func update(_ transaction: Transaction) async throws
    func delete(_ id: UUID) async throws
}
