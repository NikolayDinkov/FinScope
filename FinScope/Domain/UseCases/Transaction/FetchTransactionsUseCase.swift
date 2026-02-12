import Foundation

struct FetchTransactionsUseCase: Sendable {
    private let repository: TransactionRepositoryProtocol

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for accountId: UUID? = nil) async throws -> [Transaction] {
        if let accountId {
            return try await repository.fetchAll(for: accountId)
        }
        return try await repository.fetchAll()
    }
}
