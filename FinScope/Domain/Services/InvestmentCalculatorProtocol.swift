import Foundation

protocol InvestmentCalculatorProtocol: Sendable {
    func simulate(investment: Investment, strategy: any InvestmentStrategy, months: Int) -> [MonthlyProjection]
    func totalReturn(projections: [MonthlyProjection], initialCapital: Decimal) -> Decimal
}
