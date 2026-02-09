import Foundation

struct FetchTransactionsUseCase: Sendable {
    private let repository: any TransactionRepositoryProtocol

    init(repository: any TransactionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(accountId: UUID) async throws -> [Transaction] {
        try await repository.fetchByAccount(accountId)
    }

    func execute(from: Date, to: Date) async throws -> [Transaction] {
        try await repository.fetchInDateRange(from: from, to: to)
    }

    func executeAll() async throws -> [Transaction] {
        try await repository.fetchAll()
    }
}
