import Foundation

enum AccountDeletionError: Error, Equatable {
    case accountHasTransactions
    case accountNotFound
}

struct DeleteAccountUseCase: Sendable {
    private let repository: AccountRepositoryProtocol

    init(repository: AccountRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID) async throws {
        guard try await repository.fetchById(id) != nil else {
            throw AccountDeletionError.accountNotFound
        }

        if try await repository.hasTransactions(id) {
            throw AccountDeletionError.accountHasTransactions
        }

        try await repository.delete(id)
    }
}
