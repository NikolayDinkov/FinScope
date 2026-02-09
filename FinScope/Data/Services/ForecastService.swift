import Foundation

struct ForecastService: ForecastServiceProtocol {
    private let accountRepository: any AccountRepositoryProtocol
    private let transactionRepository: any TransactionRepositoryProtocol
    private let investmentCalculator: any InvestmentCalculatorProtocol

    init(accountRepository: any AccountRepositoryProtocol,
         transactionRepository: any TransactionRepositoryProtocol,
         investmentCalculator: any InvestmentCalculatorProtocol) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.investmentCalculator = investmentCalculator
    }

    func generateForecast(userId: UUID, months: Int) async throws -> Forecast {
        let transactions = try await transactionRepository.fetchAll()
        let recentTransactions = transactions.filter { $0.date.isInCurrentMonth || $0.date.isInCurrentYear }

        // Calculate average monthly income and expenses
        let monthCount = max(1, Set(recentTransactions.map { Calendar.current.component(.month, from: $0.date) }).count)
        let totalIncome = recentTransactions.filter { $0.type == .income }.reduce(Decimal.zero) { $0 + $1.amount }
        let totalExpenses = recentTransactions.filter { $0.type == .expense }.reduce(Decimal.zero) { $0 + $1.amount }
        let avgMonthlyIncome = (totalIncome / Decimal(monthCount)).rounded(scale: 2)
        let avgMonthlyExpenses = (totalExpenses / Decimal(monthCount)).rounded(scale: 2)

        var projections: [ForecastMonth] = []
        var cumulativeSavings: Decimal = 0
        var investmentValue: Decimal = 0

        for month in 1...months {
            let monthlySavings = avgMonthlyIncome - avgMonthlyExpenses
            cumulativeSavings += monthlySavings
            investmentValue = investmentValue * (1 + Decimal(string: "0.005833")!) // ~7% annual
            investmentValue = investmentValue.rounded(scale: 2)

            projections.append(ForecastMonth(
                month: month,
                income: avgMonthlyIncome,
                expenses: avgMonthlyExpenses,
                savings: cumulativeSavings,
                investmentValue: investmentValue,
                netWorth: cumulativeSavings + investmentValue
            ))
        }

        return Forecast(
            name: "Forecast \(DateFormatter.monthYear.string(from: Date()))",
            projectionMonths: months,
            monthlyProjections: projections,
            userId: userId
        )
    }

    func compareScenarios(_ scenarios: [Forecast]) -> ScenarioComparison {
        guard let maxMonths = scenarios.map(\.projectionMonths).max() else {
            return ScenarioComparison(scenarios: scenarios, differencesByMonth: [])
        }

        var differencesByMonth: [[Decimal]] = []

        for month in 0..<maxMonths {
            var monthDiffs: [Decimal] = []
            let baseNetWorth = scenarios.first?.monthlyProjections[safe: month]?.netWorth ?? 0

            for scenario in scenarios.dropFirst() {
                let netWorth = scenario.monthlyProjections[safe: month]?.netWorth ?? 0
                monthDiffs.append(netWorth - baseNetWorth)
            }
            differencesByMonth.append(monthDiffs)
        }

        return ScenarioComparison(scenarios: scenarios, differencesByMonth: differencesByMonth)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
