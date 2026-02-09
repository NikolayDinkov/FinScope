import Foundation
import Combine

struct BudgetAlert: Equatable, Sendable {
    let budget: Budget
    let rule: BudgetRule
    let currentSpending: Decimal
    let limit: Decimal

    var isOverBudget: Bool {
        currentSpending > limit
    }

    var percentUsed: Decimal {
        guard limit > 0 else { return 0 }
        return (currentSpending / limit).rounded(scale: 4)
    }
}

struct BudgetStatus: Equatable, Sendable {
    let budget: Budget
    let totalSpending: Decimal
    let ruleStatuses: [RuleStatus]
    let isOverBudget: Bool
}

struct RuleStatus: Equatable, Sendable {
    let rule: BudgetRule
    let currentSpending: Decimal
    let limit: Decimal
    let isExceeded: Bool
}

protocol BudgetServiceProtocol: Sendable {
    var alertPublisher: AnyPublisher<BudgetAlert, Never> { get }
    func evaluate(budget: Budget, transactions: [Transaction]) -> BudgetStatus
}
