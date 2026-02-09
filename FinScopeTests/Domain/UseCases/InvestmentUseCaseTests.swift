import Testing
@testable import FinScope

@Suite("Investment Use Case Tests")
struct InvestmentUseCaseTests {

    @Test("CreatePortfolio succeeds")
    func createPortfolioSuccess() async throws {
        let repo = MockPortfolioRepository()
        let useCase = CreatePortfolioUseCase(repository: repo)
        let userId = UUID()

        let portfolio = try await useCase.execute(name: "My Portfolio", userId: userId)

        #expect(portfolio.name == "My Portfolio")
        #expect(repo.saveCalled)
    }

    @Test("CreatePortfolio fails with empty name")
    func createPortfolioEmptyName() async {
        let repo = MockPortfolioRepository()
        let useCase = CreatePortfolioUseCase(repository: repo)

        await #expect(throws: PortfolioError.self) {
            try await useCase.execute(name: "  ", userId: UUID())
        }
    }

    @Test("SimulatePortfolio returns projections")
    func simulatePortfolio() {
        let calculator = MockInvestmentCalculator()
        calculator.stubbedProjections = [
            MonthlyProjection(month: 1, balance: 10050, contribution: 0, interest: 50),
            MonthlyProjection(month: 2, balance: 10100.25, contribution: 0, interest: 50.25)
        ]
        calculator.stubbedTotalReturn = 100.25

        let useCase = SimulatePortfolioUseCase(investmentCalculator: calculator)
        let investment = Investment(
            assetType: .etf,
            name: "Test",
            initialCapital: 10000,
            expectedReturn: Decimal(string: "0.06")!,
            riskProfile: .medium,
            durationMonths: 12,
            portfolioId: UUID()
        )

        let projections = useCase.execute(
            investment: investment,
            strategy: CompoundInterestStrategy(),
            months: 2
        )

        #expect(projections.count == 2)
        #expect(calculator.simulateCalled)

        let totalReturn = useCase.totalReturn(projections: projections, initialCapital: 10000)
        #expect(totalReturn == 100.25)
    }
}
