import Foundation
@testable import FinScope

final class MockAccountRepository: AccountRepositoryProtocol, @unchecked Sendable {
    var accounts: [Account] = []
    var shouldThrow = false
    var hasTransactionsResult = false

    func fetchAll() async throws -> [Account] {
        if shouldThrow { throw MockError.generic }
        return accounts
    }

    func fetchById(_ id: UUID) async throws -> Account? {
        if shouldThrow { throw MockError.generic }
        return accounts.first { $0.id == id }
    }

    func create(_ account: Account) async throws {
        if shouldThrow { throw MockError.generic }
        accounts.append(account)
    }

    func update(_ account: Account) async throws {
        if shouldThrow { throw MockError.generic }
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        }
    }

    func delete(_ id: UUID) async throws {
        if shouldThrow { throw MockError.generic }
        accounts.removeAll { $0.id == id }
    }

    func hasTransactions(_ accountId: UUID) async throws -> Bool {
        if shouldThrow { throw MockError.generic }
        return hasTransactionsResult
    }
}

enum MockError: Error {
    case generic
}
