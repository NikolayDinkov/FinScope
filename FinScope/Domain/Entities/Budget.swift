import Foundation

struct Budget: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var period: BudgetPeriod
    var startDate: Date
    var endDate: Date?
    var totalLimit: Decimal?
    var userId: UUID
    var rules: [BudgetRule]

    init(
        id: UUID = UUID(),
        name: String,
        period: BudgetPeriod,
        startDate: Date = Date(),
        endDate: Date? = nil,
        totalLimit: Decimal? = nil,
        userId: UUID,
        rules: [BudgetRule] = []
    ) {
        self.id = id
        self.name = name
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.totalLimit = totalLimit
        self.userId = userId
        self.rules = rules
    }
}

enum BudgetPeriod: String, CaseIterable, Sendable, Codable {
    case monthly
    case yearly
}
