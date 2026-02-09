import Foundation

struct InvestmentCalculator: InvestmentCalculatorProtocol {
    func simulate(investment: Investment, strategy: any InvestmentStrategy, months: Int) -> [MonthlyProjection] {
        strategy.calculate(investment: investment, months: months)
    }

    func totalReturn(projections: [MonthlyProjection], initialCapital: Decimal) -> Decimal {
        guard let last = projections.last else { return 0 }
        let totalContributions = projections.reduce(Decimal.zero) { $0 + $1.contribution }
        return last.balance - initialCapital - totalContributions
    }
}
