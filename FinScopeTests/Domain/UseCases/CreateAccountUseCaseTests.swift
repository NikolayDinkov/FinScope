import Testing
import Foundation
@testable import FinScope

struct CreateAccountUseCaseTests {
    @Test func testCreateAccountAddsToRepository() async throws {
        let repo = MockAccountRepository()
        let useCase = CreateAccountUseCase(repository: repo)
        let account = Account(name: "New Account", type: .bank)
        try await useCase.execute(account)
        #expect(repo.accounts.count == 1)
        #expect(repo.accounts.first?.name == "New Account")
    }
}
