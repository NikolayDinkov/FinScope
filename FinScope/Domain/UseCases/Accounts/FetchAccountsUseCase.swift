import Foundation

struct FetchAccountsUseCase: Sendable {
    private let repository: any AccountRepositoryProtocol

    init(repository: any AccountRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: UUID) async throws -> [Account] {
        try await repository.fetchByUser(userId)
    }

    func executeAll() async throws -> [Account] {
        try await repository.fetchAll()
    }
}
