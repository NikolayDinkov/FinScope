import Foundation
@testable import FinScope

final class MockInvestmentCalculator: InvestmentCalculatorProtocol, @unchecked Sendable {
    var stubbedProjections: [MonthlyProjection] = []
    var stubbedTotalReturn: Decimal = 0
    var simulateCalled = false

    func simulate(investment: Investment, strategy: any InvestmentStrategy, months: Int) -> [MonthlyProjection] {
        simulateCalled = true
        if stubbedProjections.isEmpty {
            return strategy.calculate(investment: investment, months: months)
        }
        return stubbedProjections
    }

    func totalReturn(projections: [MonthlyProjection], initialCapital: Decimal) -> Decimal {
        stubbedTotalReturn
    }
}
