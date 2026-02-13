import Foundation

struct ForecastService: ForecastServiceProtocol {

    func generateForecast(
        accounts: [Account],
        transactions: [Transaction],
        horizon: ForecastHorizon,
        referenceDate: Date
    ) async throws -> [MonthlyForecast] {
        let currentBalance = accounts.reduce(Decimal.zero) { $0 + $1.balance }

        let recurringTransactions = transactions.filter { $0.isRecurring && $0.recurrenceRule != nil }

        let threeMonthsAgo = referenceDate.adding(months: -3).startOfMonth
        let historicalExpenses = transactions.filter { tx in
            tx.type == .expense
            && !tx.isRecurring
            && tx.date >= threeMonthsAgo
            && tx.date <= referenceDate
        }
        let totalHistoricalExpense = historicalExpenses.reduce(Decimal.zero) { $0 + $1.amount }
        let averageMonthlyNonRecurringExpense = (totalHistoricalExpense / 3).rounded(scale: 2)

        var forecasts: [MonthlyForecast] = []
        var runningBalance = currentBalance

        for monthOffset in 1...horizon.rawValue {
            let monthDate = referenceDate.adding(months: monthOffset).startOfMonth

            let recurringIncome = recurringTransactions
                .filter { $0.type == .income }
                .reduce(Decimal.zero) { sum, tx in
                    sum + monthlyAmount(for: tx.recurrenceRule!, amount: tx.amount)
                }

            let recurringExpense = recurringTransactions
                .filter { $0.type == .expense }
                .reduce(Decimal.zero) { sum, tx in
                    sum + monthlyAmount(for: tx.recurrenceRule!, amount: tx.amount)
                }
            let totalExpenses = recurringExpense + averageMonthlyNonRecurringExpense

            let netCashFlow = recurringIncome - totalExpenses
            runningBalance += netCashFlow

            let forecast = MonthlyForecast(
                month: monthDate,
                projectedIncome: recurringIncome.rounded(scale: 2),
                projectedExpenses: totalExpenses.rounded(scale: 2),
                netCashFlow: netCashFlow.rounded(scale: 2),
                projectedBalance: runningBalance.rounded(scale: 2)
            )
            forecasts.append(forecast)
        }

        return forecasts
    }

    private func monthlyAmount(for rule: RecurrenceRule, amount: Decimal) -> Decimal {
        switch rule.frequency {
        case .daily:
            return amount * 30
        case .weekly:
            return amount * Decimal(string: "4.33")!
        case .biweekly:
            return amount * Decimal(string: "2.17")!
        case .monthly:
            return amount
        case .quarterly:
            return (amount / 3).rounded(scale: 2)
        case .yearly:
            return (amount / 12).rounded(scale: 2)
        }
    }
}
