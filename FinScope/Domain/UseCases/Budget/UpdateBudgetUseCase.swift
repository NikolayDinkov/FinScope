import Foundation

struct UpdateBudgetUseCase: Sendable {
    private let repository: BudgetRepositoryProtocol

    init(repository: BudgetRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ budget: Budget) async throws {
        var updated = budget
        updated.updatedAt = Date()
        try await repository.update(updated)
    }
}
