import Foundation

struct CompoundInterestStrategy: InvestmentStrategy {
    func calculate(investment: Investment, months: Int) -> [MonthlyProjection] {
        DecimalCalculator.monthlyProjection(
            initialCapital: investment.initialCapital,
            monthlyContribution: investment.monthlyContribution,
            annualRate: investment.expectedReturn,
            months: months
        )
    }
}
