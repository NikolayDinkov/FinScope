import Foundation

protocol InvestmentStrategy: Sendable {
    func calculate(investment: Investment, months: Int) -> [MonthlyProjection]
}
