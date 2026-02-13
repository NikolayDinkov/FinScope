import Foundation

struct MonthlyForecast: Identifiable, Equatable, Sendable {
    let id: UUID
    let month: Date
    let projectedIncome: Decimal
    let projectedExpenses: Decimal
    let netCashFlow: Decimal
    let projectedBalance: Decimal

    init(
        id: UUID = UUID(),
        month: Date,
        projectedIncome: Decimal,
        projectedExpenses: Decimal,
        netCashFlow: Decimal,
        projectedBalance: Decimal
    ) {
        self.id = id
        self.month = month
        self.projectedIncome = projectedIncome
        self.projectedExpenses = projectedExpenses
        self.netCashFlow = netCashFlow
        self.projectedBalance = projectedBalance
    }
}
