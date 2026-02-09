import Testing
@testable import FinScope

@Suite("Investment Strategy Tests")
struct StrategyTests {

    private func makeInvestment(
        initialCapital: Decimal = 10000,
        monthlyContribution: Decimal = 500,
        expectedReturn: Decimal = Decimal(string: "0.12")!
    ) -> Investment {
        Investment(
            assetType: .etf,
            name: "Test",
            initialCapital: initialCapital,
            monthlyContribution: monthlyContribution,
            expectedReturn: expectedReturn,
            riskProfile: .medium,
            durationMonths: 12,
            portfolioId: UUID()
        )
    }

    // MARK: - Compound Interest Strategy

    @Test("Compound interest produces correct number of months")
    func compoundInterestMonths() {
        let strategy = CompoundInterestStrategy()
        let investment = makeInvestment()
        let projections = strategy.calculate(investment: investment, months: 12)

        #expect(projections.count == 12)
        #expect(projections.first?.month == 1)
        #expect(projections.last?.month == 12)
    }

    @Test("Compound interest balance increases over time")
    func compoundInterestGrowth() {
        let strategy = CompoundInterestStrategy()
        let investment = makeInvestment()
        let projections = strategy.calculate(investment: investment, months: 12)

        for i in 1..<projections.count {
            #expect(projections[i].balance > projections[i - 1].balance)
        }
    }

    @Test("Compound interest is deterministic")
    func compoundInterestDeterministic() {
        let strategy = CompoundInterestStrategy()
        let investment = makeInvestment()

        let run1 = strategy.calculate(investment: investment, months: 12)
        let run2 = strategy.calculate(investment: investment, months: 12)

        for i in 0..<run1.count {
            #expect(run1[i].balance == run2[i].balance)
            #expect(run1[i].interest == run2[i].interest)
        }
    }

    @Test("Compound interest with zero contribution")
    func compoundInterestZeroContribution() {
        let strategy = CompoundInterestStrategy()
        let investment = makeInvestment(monthlyContribution: 0)
        let projections = strategy.calculate(investment: investment, months: 12)

        #expect(projections.first!.balance > 10000)
        for p in projections {
            #expect(p.contribution == 0)
        }
    }

    // MARK: - DCA Strategy

    @Test("DCA spreads initial capital over N months")
    func dcaSpread() {
        let strategy = DCAStrategy(spreadMonths: 6)
        let investment = makeInvestment(monthlyContribution: 0)
        let projections = strategy.calculate(investment: investment, months: 12)

        // First 6 months should have contributions (DCA amount)
        let dcaAmount = Decimal(10000) / Decimal(6)
        for i in 0..<6 {
            #expect(projections[i].contribution == dcaAmount)
        }
        // Months 7-12 should have 0 contribution
        for i in 6..<12 {
            #expect(projections[i].contribution == 0)
        }
    }

    @Test("DCA produces correct month count")
    func dcaMonthCount() {
        let strategy = DCAStrategy()
        let investment = makeInvestment()
        let projections = strategy.calculate(investment: investment, months: 24)
        #expect(projections.count == 24)
    }

    // MARK: - Fixed Income Strategy

    @Test("Fixed income produces consistent coupons on principal")
    func fixedIncomeCoupons() {
        let strategy = FixedIncomeStrategy()
        let investment = makeInvestment(
            initialCapital: 10000,
            monthlyContribution: 0,
            expectedReturn: Decimal(string: "0.06")!
        )
        let projections = strategy.calculate(investment: investment, months: 3)

        // Monthly rate = 0.06/12 = 0.005
        // First month coupon on principal = 10000 * 0.005 = 50
        #expect(projections[0].interest == 50)
        #expect(projections.count == 3)
    }

    @Test("Fixed income balance grows monotonically")
    func fixedIncomeGrowth() {
        let strategy = FixedIncomeStrategy()
        let investment = makeInvestment()
        let projections = strategy.calculate(investment: investment, months: 12)

        for i in 1..<projections.count {
            #expect(projections[i].balance >= projections[i - 1].balance)
        }
    }

    // MARK: - InvestmentCalculator (Strategy Pattern Host)

    @Test("InvestmentCalculator delegates to strategy")
    func calculatorDelegation() {
        let calculator = InvestmentCalculator()
        let investment = makeInvestment()

        let compound = calculator.simulate(
            investment: investment,
            strategy: CompoundInterestStrategy(),
            months: 6
        )
        let dca = calculator.simulate(
            investment: investment,
            strategy: DCAStrategy(),
            months: 6
        )

        // Different strategies should produce different results
        #expect(compound.last!.balance != dca.last!.balance)
    }

    @Test("InvestmentCalculator totalReturn correct")
    func calculatorTotalReturn() {
        let calculator = InvestmentCalculator()
        let projections = [
            MonthlyProjection(month: 1, balance: 10600, contribution: 500, interest: 100),
            MonthlyProjection(month: 2, balance: 11210, contribution: 500, interest: 110),
        ]

        let totalReturn = calculator.totalReturn(projections: projections, initialCapital: 10000)
        // Final balance (11210) - initial (10000) - total contributions (1000) = 210
        #expect(totalReturn == 210)
    }
}
