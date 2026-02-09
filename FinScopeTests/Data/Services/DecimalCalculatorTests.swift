import Testing
@testable import FinScope

@Suite("DecimalCalculator Tests")
struct DecimalCalculatorTests {

    @Test("Monthly projection produces correct count")
    func monthlyProjectionCount() {
        let projections = DecimalCalculator.monthlyProjection(
            initialCapital: 1000,
            monthlyContribution: 100,
            annualRate: Decimal(string: "0.12")!,
            months: 12
        )
        #expect(projections.count == 12)
    }

    @Test("Monthly projection balance increases")
    func monthlyProjectionGrowth() {
        let projections = DecimalCalculator.monthlyProjection(
            initialCapital: 10000,
            monthlyContribution: 500,
            annualRate: Decimal(string: "0.06")!,
            months: 12
        )

        for i in 1..<projections.count {
            #expect(projections[i].balance > projections[i - 1].balance)
        }
    }

    @Test("Monthly projection is deterministic")
    func monthlyProjectionDeterministic() {
        let run1 = DecimalCalculator.monthlyProjection(
            initialCapital: 10000,
            monthlyContribution: 500,
            annualRate: Decimal(string: "0.07")!,
            months: 24
        )
        let run2 = DecimalCalculator.monthlyProjection(
            initialCapital: 10000,
            monthlyContribution: 500,
            annualRate: Decimal(string: "0.07")!,
            months: 24
        )

        for i in 0..<run1.count {
            #expect(run1[i] == run2[i])
        }
    }

    @Test("Future value of annuity with zero rate")
    func futureValueZeroRate() {
        let fv = DecimalCalculator.futureValueOfAnnuity(
            payment: 100,
            ratePerPeriod: 0,
            periods: 12
        )
        #expect(fv == 1200)
    }

    @Test("Future value of annuity with positive rate")
    func futureValuePositiveRate() {
        let fv = DecimalCalculator.futureValueOfAnnuity(
            payment: 100,
            ratePerPeriod: Decimal(string: "0.01")!,
            periods: 12
        )
        // Should be more than 1200 due to compounding
        #expect(fv > 1200)
    }

    @Test("After-tax calculation")
    func afterTax() {
        let result = DecimalCalculator.afterTax(
            gains: 1000,
            taxRate: Decimal(string: "0.10")!
        )
        #expect(result == 900)
    }

    @Test("Inflation adjustment reduces value")
    func inflationAdjustment() {
        let adjusted = DecimalCalculator.adjustForInflation(
            amount: 10000,
            inflationRate: Decimal(string: "0.03")!,
            years: 10
        )
        #expect(adjusted < 10000)
        #expect(adjusted > 0)
    }
}
