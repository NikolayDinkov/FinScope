import Foundation

/// Deterministic decimal math operations for financial calculations.
/// Uses Foundation's Decimal type to avoid floating-point precision issues.
enum DecimalCalculator {
    /// Compound interest: P * (1 + r/n)^(n*t)
    /// - Parameters:
    ///   - principal: Initial amount
    ///   - annualRate: Annual interest rate as decimal (e.g. 0.07 for 7%)
    ///   - compoundingsPerYear: Number of times interest compounds per year
    ///   - years: Number of years
    /// - Returns: Final amount after compound interest
    static func compoundInterest(
        principal: Decimal,
        annualRate: Decimal,
        compoundingsPerYear: Int = 12,
        years: Decimal
    ) -> Decimal {
        let n = Decimal(compoundingsPerYear)
        let ratePerPeriod = annualRate / n
        let periods = n * years
        let base = 1 + ratePerPeriod
        let multiplier = pow(base, Int(truncating: NSDecimalNumber(decimal: periods)))
        return (principal * multiplier).rounded(scale: 2)
    }

    /// Future value of a series of regular payments (annuity)
    /// FV = PMT * [((1 + r)^n - 1) / r]
    static func futureValueOfAnnuity(
        payment: Decimal,
        ratePerPeriod: Decimal,
        periods: Int
    ) -> Decimal {
        guard ratePerPeriod > 0 else {
            return payment * Decimal(periods)
        }
        let base = 1 + ratePerPeriod
        let growth = pow(base, periods) - 1
        return (payment * growth / ratePerPeriod).rounded(scale: 2)
    }

    /// Monthly projection for compound interest with regular contributions
    static func monthlyProjection(
        initialCapital: Decimal,
        monthlyContribution: Decimal,
        annualRate: Decimal,
        months: Int
    ) -> [MonthlyProjection] {
        let monthlyRate = annualRate / 12
        var balance = initialCapital
        var projections: [MonthlyProjection] = []

        for month in 1...months {
            let interest = (balance * monthlyRate).rounded(scale: 2)
            balance += interest + monthlyContribution
            balance = balance.rounded(scale: 2)

            projections.append(MonthlyProjection(
                month: month,
                balance: balance,
                contribution: monthlyContribution,
                interest: interest
            ))
        }

        return projections
    }

    /// Adjust a nominal value for inflation
    static func adjustForInflation(
        amount: Decimal,
        inflationRate: Decimal,
        years: Decimal
    ) -> Decimal {
        let divisor = pow(1 + inflationRate, Int(truncating: NSDecimalNumber(decimal: years)))
        guard divisor > 0 else { return amount }
        return (amount / divisor).rounded(scale: 2)
    }

    /// Apply tax rate to gains
    static func afterTax(gains: Decimal, taxRate: Decimal) -> Decimal {
        (gains * (1 - taxRate)).rounded(scale: 2)
    }
}

struct MonthlyProjection: Equatable, Sendable {
    let month: Int
    let balance: Decimal
    let contribution: Decimal
    let interest: Decimal
}
