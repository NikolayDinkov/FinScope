import Testing
import Foundation
@testable import FinScope

struct DeleteAccountUseCaseTests {
    @Test func testDeleteAccountWithNoTransactions() async throws {
        let repo = MockAccountRepository()
        let account = Account(name: "Test", type: .bank)
        repo.accounts = [account]
        repo.hasTransactionsResult = false

        let useCase = DeleteAccountUseCase(repository: repo)
        try await useCase.execute(id: account.id)
        #expect(repo.accounts.isEmpty)
    }

    @Test func testDeleteAccountWithTransactionsThrows() async throws {
        let repo = MockAccountRepository()
        let account = Account(name: "Test", type: .bank)
        repo.accounts = [account]
        repo.hasTransactionsResult = true

        let useCase = DeleteAccountUseCase(repository: repo)
        await #expect(throws: AccountDeletionError.accountHasTransactions) {
            try await useCase.execute(id: account.id)
        }
        #expect(repo.accounts.count == 1)
    }

    @Test func testDeleteNonExistentAccountThrows() async throws {
        let repo = MockAccountRepository()
        let useCase = DeleteAccountUseCase(repository: repo)
        await #expect(throws: AccountDeletionError.accountNotFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
