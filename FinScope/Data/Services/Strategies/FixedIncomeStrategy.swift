import Foundation

/// Fixed-income (bonds) strategy.
/// Returns a fixed coupon payment each period on the initial capital,
/// plus any monthly contributions grow at the same fixed rate.
struct FixedIncomeStrategy: InvestmentStrategy {
    func calculate(investment: Investment, months: Int) -> [MonthlyProjection] {
        let monthlyRate = investment.expectedReturn / 12
        let monthlyCoupon = (investment.initialCapital * monthlyRate).rounded(scale: 2)
        var balance = investment.initialCapital
        var projections: [MonthlyProjection] = []

        for month in 1...months {
            let interest = monthlyCoupon + (balance - investment.initialCapital) * monthlyRate
            let roundedInterest = interest.rounded(scale: 2)
            balance += roundedInterest + investment.monthlyContribution
            balance = balance.rounded(scale: 2)

            projections.append(MonthlyProjection(
                month: month,
                balance: balance,
                contribution: investment.monthlyContribution,
                interest: roundedInterest
            ))
        }

        return projections
    }
}
