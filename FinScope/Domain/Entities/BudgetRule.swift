import Foundation

struct BudgetRule: Identifiable, Equatable, Sendable {
    let id: UUID
    var ruleType: BudgetRuleType
    var limitAmount: Decimal?
    var percentage: Decimal?
    var budgetId: UUID
    var categoryId: UUID

    init(
        id: UUID = UUID(),
        ruleType: BudgetRuleType,
        limitAmount: Decimal? = nil,
        percentage: Decimal? = nil,
        budgetId: UUID,
        categoryId: UUID
    ) {
        self.id = id
        self.ruleType = ruleType
        self.limitAmount = limitAmount
        self.percentage = percentage
        self.budgetId = budgetId
        self.categoryId = categoryId
    }
}

enum BudgetRuleType: String, CaseIterable, Sendable, Codable {
    case fixedLimit
    case percentageOfIncome
}
