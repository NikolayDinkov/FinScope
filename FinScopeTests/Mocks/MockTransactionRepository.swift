import Foundation
@testable import FinScope

final class MockTransactionRepository: TransactionRepositoryProtocol, @unchecked Sendable {
    var transactions: [FinScope.Transaction] = []
    var shouldThrow = false

    func fetchAll() async throws -> [FinScope.Transaction] {
        if shouldThrow { throw MockError.generic }
        return transactions
    }

    func fetchAll(for accountId: UUID) async throws -> [FinScope.Transaction] {
        if shouldThrow { throw MockError.generic }
        return transactions.filter { $0.accountId == accountId }
    }

    func fetchById(_ id: UUID) async throws -> FinScope.Transaction? {
        if shouldThrow { throw MockError.generic }
        return transactions.first { $0.id == id }
    }

    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [FinScope.Transaction] {
        if shouldThrow { throw MockError.generic }
        return transactions.filter { $0.date >= startDate && $0.date <= endDate }
    }

    func create(_ transaction: FinScope.Transaction) async throws {
        if shouldThrow { throw MockError.generic }
        transactions.append(transaction)
    }

    func update(_ transaction: FinScope.Transaction) async throws {
        if shouldThrow { throw MockError.generic }
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        }
    }

    func delete(_ id: UUID) async throws {
        if shouldThrow { throw MockError.generic }
        transactions.removeAll { $0.id == id }
    }
}
