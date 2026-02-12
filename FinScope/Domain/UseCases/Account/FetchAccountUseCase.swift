import Foundation

struct FetchAccountUseCase: Sendable {
    private let repository: AccountRepositoryProtocol

    init(repository: AccountRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID) async throws -> Account? {
        try await repository.fetchById(id)
    }
}
