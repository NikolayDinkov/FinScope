import Foundation

@Observable
final class SimulatorViewModel {
    private let simulatePortfolio: SimulatePortfolioUseCase
    private let assetFactory: AssetFactoryProtocol

    let portfolio: Portfolio
    var projections: [MonthlyProjection] = []
    var totalReturn: Decimal = 0
    var selectedStrategy: StrategyType = .compoundInterest
    var simulationMonths: Int = 120
    var errorMessage: String?

    init(portfolio: Portfolio, simulatePortfolio: SimulatePortfolioUseCase, assetFactory: AssetFactoryProtocol) {
        self.portfolio = portfolio
        self.simulatePortfolio = simulatePortfolio
        self.assetFactory = assetFactory
    }

    func simulate() {
        guard let firstInvestment = portfolio.investments.first else {
            errorMessage = "Add at least one investment to simulate"
            return
        }

        let strategy: any InvestmentStrategy = switch selectedStrategy {
        case .compoundInterest: CompoundInterestStrategy()
        case .dca: DCAStrategy()
        case .fixedIncome: FixedIncomeStrategy()
        }

        projections = simulatePortfolio.execute(
            investment: firstInvestment,
            strategy: strategy,
            months: simulationMonths
        )
        totalReturn = simulatePortfolio.totalReturn(
            projections: projections,
            initialCapital: firstInvestment.initialCapital
        )
    }
}

enum StrategyType: String, CaseIterable {
    case compoundInterest = "Compound Interest"
    case dca = "Dollar-Cost Averaging"
    case fixedIncome = "Fixed Income"
}
