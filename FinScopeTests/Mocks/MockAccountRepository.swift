import Foundation
@testable import FinScope

final class MockAccountRepository: AccountRepositoryProtocol, @unchecked Sendable {
    var accounts: [Account] = []
    var shouldThrow = false
    var saveCalled = false
    var deleteCalled = false

    func fetchAll() async throws -> [Account] {
        if shouldThrow { throw MockError.testError }
        return accounts
    }

    func fetchByUser(_ userId: UUID) async throws -> [Account] {
        if shouldThrow { throw MockError.testError }
        return accounts.filter { $0.userId == userId }
    }

    func fetch(byId id: UUID) async throws -> Account? {
        if shouldThrow { throw MockError.testError }
        return accounts.first { $0.id == id }
    }

    func save(_ account: Account) async throws {
        if shouldThrow { throw MockError.testError }
        saveCalled = true
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        } else {
            accounts.append(account)
        }
    }

    func delete(_ account: Account) async throws {
        if shouldThrow { throw MockError.testError }
        deleteCalled = true
        accounts.removeAll { $0.id == account.id }
    }
}

enum MockError: Error {
    case testError
}
