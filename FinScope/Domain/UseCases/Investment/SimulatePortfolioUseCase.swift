import Foundation

struct SimulatePortfolioUseCase: Sendable {
    private let investmentCalculator: any InvestmentCalculatorProtocol

    init(investmentCalculator: any InvestmentCalculatorProtocol) {
        self.investmentCalculator = investmentCalculator
    }

    func execute(investment: Investment, strategy: any InvestmentStrategy, months: Int) -> [MonthlyProjection] {
        investmentCalculator.simulate(investment: investment, strategy: strategy, months: months)
    }

    func totalReturn(projections: [MonthlyProjection], initialCapital: Decimal) -> Decimal {
        investmentCalculator.totalReturn(projections: projections, initialCapital: initialCapital)
    }
}
