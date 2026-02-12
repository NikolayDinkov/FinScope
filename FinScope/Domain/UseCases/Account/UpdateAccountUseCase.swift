import Foundation

struct UpdateAccountUseCase: Sendable {
    private let repository: AccountRepositoryProtocol

    init(repository: AccountRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ account: Account) async throws {
        var updated = account
        updated.updatedAt = Date()
        try await repository.update(updated)
    }
}
