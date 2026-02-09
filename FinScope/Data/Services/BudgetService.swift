import Foundation
import Combine

final class BudgetService: BudgetServiceProtocol, @unchecked Sendable {
    private let budgetRepository: any BudgetRepositoryProtocol
    private let transactionRepository: any TransactionRepositoryProtocol
    private let alertSubject = PassthroughSubject<BudgetAlert, Never>()

    var alertPublisher: AnyPublisher<BudgetAlert, Never> {
        alertSubject.eraseToAnyPublisher()
    }

    init(budgetRepository: any BudgetRepositoryProtocol,
         transactionRepository: any TransactionRepositoryProtocol) {
        self.budgetRepository = budgetRepository
        self.transactionRepository = transactionRepository
    }

    func evaluate(budget: Budget, transactions: [Transaction]) -> BudgetStatus {
        let expenseTransactions = transactions.filter { $0.type == .expense }
        let totalSpending = expenseTransactions.reduce(Decimal.zero) { $0 + $1.amount }

        var ruleStatuses: [RuleStatus] = []
        var isOverBudget = false

        // Check total limit
        if let totalLimit = budget.totalLimit, totalSpending > totalLimit {
            isOverBudget = true
        }

        // Check per-category rules
        for rule in budget.rules {
            let categorySpending = expenseTransactions
                .filter { $0.categoryId == rule.categoryId }
                .reduce(Decimal.zero) { $0 + $1.amount }

            let limit: Decimal
            switch rule.ruleType {
            case .fixedLimit:
                limit = rule.limitAmount ?? 0
            case .percentageOfIncome:
                let totalIncome = transactions
                    .filter { $0.type == .income }
                    .reduce(Decimal.zero) { $0 + $1.amount }
                limit = totalIncome * (rule.percentage ?? 0)
            }

            let isExceeded = categorySpending > limit
            if isExceeded {
                isOverBudget = true
                alertSubject.send(BudgetAlert(
                    budget: budget,
                    rule: rule,
                    currentSpending: categorySpending,
                    limit: limit
                ))
            }

            ruleStatuses.append(RuleStatus(
                rule: rule,
                currentSpending: categorySpending,
                limit: limit,
                isExceeded: isExceeded
            ))
        }

        return BudgetStatus(
            budget: budget,
            totalSpending: totalSpending,
            ruleStatuses: ruleStatuses,
            isOverBudget: isOverBudget
        )
    }
}
