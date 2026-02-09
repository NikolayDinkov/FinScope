import Foundation
@testable import FinScope

final class MockTransactionRepository: TransactionRepositoryProtocol, @unchecked Sendable {
    var transactions: [Transaction] = []
    var shouldThrow = false
    var saveCalled = false
    var saveAllCalled = false
    var deleteCalled = false

    func fetchAll() async throws -> [Transaction] {
        if shouldThrow { throw MockError.testError }
        return transactions
    }

    func fetchByAccount(_ accountId: UUID) async throws -> [Transaction] {
        if shouldThrow { throw MockError.testError }
        return transactions.filter { $0.accountId == accountId }
    }

    func fetchByCategory(_ categoryId: UUID) async throws -> [Transaction] {
        if shouldThrow { throw MockError.testError }
        return transactions.filter { $0.categoryId == categoryId }
    }

    func fetchInDateRange(from: Date, to: Date) async throws -> [Transaction] {
        if shouldThrow { throw MockError.testError }
        return transactions.filter { $0.date >= from && $0.date <= to }
    }

    func fetch(byId id: UUID) async throws -> Transaction? {
        if shouldThrow { throw MockError.testError }
        return transactions.first { $0.id == id }
    }

    func save(_ transaction: Transaction) async throws {
        if shouldThrow { throw MockError.testError }
        saveCalled = true
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        } else {
            transactions.append(transaction)
        }
    }

    func saveAll(_ newTransactions: [Transaction]) async throws {
        if shouldThrow { throw MockError.testError }
        saveAllCalled = true
        transactions.append(contentsOf: newTransactions)
    }

    func delete(_ transaction: Transaction) async throws {
        if shouldThrow { throw MockError.testError }
        deleteCalled = true
        transactions.removeAll { $0.id == transaction.id }
    }

    func countByAccount(_ accountId: UUID) async throws -> Int {
        if shouldThrow { throw MockError.testError }
        return transactions.filter { $0.accountId == accountId }.count
    }
}
