import Foundation

struct FetchAccountsUseCase: Sendable {
    private let repository: AccountRepositoryProtocol

    init(repository: AccountRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Account] {
        try await repository.fetchAll()
    }
}
