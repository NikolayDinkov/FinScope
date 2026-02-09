import Foundation

/// Dollar-Cost Averaging strategy.
/// Splits the initial capital evenly over the first N months as additional contributions,
/// then continues with regular monthly contributions only.
struct DCAStrategy: InvestmentStrategy {
    let spreadMonths: Int

    init(spreadMonths: Int = 12) {
        self.spreadMonths = max(1, spreadMonths)
    }

    func calculate(investment: Investment, months: Int) -> [MonthlyProjection] {
        let monthlyRate = investment.expectedReturn / 12
        let dcaAmount = investment.initialCapital / Decimal(spreadMonths)
        var balance: Decimal = 0
        var projections: [MonthlyProjection] = []

        for month in 1...months {
            let interest = (balance * monthlyRate).rounded(scale: 2)
            let contribution: Decimal
            if month <= spreadMonths {
                contribution = dcaAmount + investment.monthlyContribution
            } else {
                contribution = investment.monthlyContribution
            }

            balance += interest + contribution
            balance = balance.rounded(scale: 2)

            projections.append(MonthlyProjection(
                month: month,
                balance: balance,
                contribution: contribution,
                interest: interest
            ))
        }

        return projections
    }
}
