import Foundation

struct FetchBudgetsUseCase: Sendable {
    private let repository: BudgetRepositoryProtocol

    init(repository: BudgetRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Budget] {
        try await repository.fetchAll()
    }
}
