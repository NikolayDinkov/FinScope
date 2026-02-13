import Foundation

struct CreateBudgetUseCase: Sendable {
    private let repository: BudgetRepositoryProtocol

    init(repository: BudgetRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ budget: Budget) async throws {
        try await repository.create(budget)
    }
}
