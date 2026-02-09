import Foundation

struct CreateBudgetUseCase: Sendable {
    private let repository: any BudgetRepositoryProtocol

    init(repository: any BudgetRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, period: BudgetPeriod, totalLimit: Decimal?, userId: UUID, rules: [BudgetRule]) async throws -> Budget {
        guard !name.trimmed.isEmpty else {
            throw BudgetError.invalidRule
        }

        let budget = Budget(
            name: name.trimmed,
            period: period,
            totalLimit: totalLimit,
            userId: userId,
            rules: rules
        )
        try await repository.save(budget)
        return budget
    }
}
