import Testing
import Foundation
@testable import FinScope

struct FetchAccountsUseCaseTests {
    @Test func testFetchAccountsReturnsAll() async throws {
        let repo = MockAccountRepository()
        repo.accounts = [
            Account(name: "Cash", type: .cash),
            Account(name: "Bank", type: .bank)
        ]
        let useCase = FetchAccountsUseCase(repository: repo)
        let result = try await useCase.execute()
        #expect(result.count == 2)
    }

    @Test func testFetchAccountsReturnsEmpty() async throws {
        let repo = MockAccountRepository()
        let useCase = FetchAccountsUseCase(repository: repo)
        let result = try await useCase.execute()
        #expect(result.isEmpty)
    }
}
