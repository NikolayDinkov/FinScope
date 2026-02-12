import Foundation

struct CreateAccountUseCase: Sendable {
    private let repository: AccountRepositoryProtocol

    init(repository: AccountRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ account: Account) async throws {
        try await repository.create(account)
    }
}
