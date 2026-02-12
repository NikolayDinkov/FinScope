import Foundation

struct CreateCategoryUseCase: Sendable {
    private let repository: CategoryRepositoryProtocol

    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ category: Category) async throws {
        try await repository.create(category)
    }
}
