import Foundation
import Combine

struct EvaluateBudgetUseCase: Sendable {
    private let budgetService: any BudgetServiceProtocol
    private let budgetRepository: any BudgetRepositoryProtocol
    private let transactionRepository: any TransactionRepositoryProtocol

    init(budgetService: any BudgetServiceProtocol,
         budgetRepository: any BudgetRepositoryProtocol,
         transactionRepository: any TransactionRepositoryProtocol) {
        self.budgetService = budgetService
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
    }

    func execute(budgetId: UUID) async throws -> BudgetStatus {
        guard let budget = try await budgetRepository.fetch(byId: budgetId) else {
            throw BudgetError.budgetNotFound
        }

        let transactions = try await transactionRepository.fetchInDateRange(
            from: budget.startDate,
            to: budget.endDate ?? Date()
        )

        return budgetService.evaluate(budget: budget, transactions: transactions)
    }

    var alertPublisher: AnyPublisher<BudgetAlert, Never> {
        budgetService.alertPublisher
    }
}

enum BudgetError: Error, LocalizedError {
    case budgetNotFound
    case invalidRule

    var errorDescription: String? {
        switch self {
        case .budgetNotFound: "Budget not found"
        case .invalidRule: "Invalid budget rule configuration"
        }
    }
}
