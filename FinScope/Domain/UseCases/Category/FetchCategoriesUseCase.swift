import Foundation

struct FetchCategoriesUseCase: Sendable {
    private let repository: CategoryRepositoryProtocol

    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(type: TransactionType? = nil) async throws -> [Category] {
        if let type {
            return try await repository.fetchByType(type)
        }
        return try await repository.fetchAll()
    }
}
