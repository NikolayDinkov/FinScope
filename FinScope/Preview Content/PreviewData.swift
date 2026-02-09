import Foundation

enum PreviewData {
    static let userId = UUID()
    static let accountId = UUID()
    static let categoryId = UUID()
    static let portfolioId = UUID()

    static let user = User(
        id: userId,
        name: "Preview User",
        email: "preview@example.com"
    )

    static let cashAccount = Account(
        id: accountId,
        name: "Cash Wallet",
        type: .cash,
        currency: "BGN",
        userId: userId
    )

    static let bankAccount = Account(
        name: "Bank Account",
        type: .bank,
        currency: "EUR",
        userId: userId
    )

    static let investmentAccount = Account(
        name: "Investment Account",
        type: .investment,
        currency: "USD",
        userId: userId
    )

    static let salaryCategory = Category(
        id: categoryId,
        name: "Salary",
        icon: "briefcase.fill",
        type: .income
    )

    static let foodCategory = Category(
        name: "Food & Dining",
        icon: "fork.knife",
        type: .expense
    )

    static let incomeTransaction = Transaction(
        amount: Decimal(string: "3500.00")!,
        date: Date(),
        note: "Monthly Salary",
        type: .income,
        accountId: accountId,
        categoryId: categoryId
    )

    static let expenseTransaction = Transaction(
        amount: Decimal(string: "45.50")!,
        date: Date(),
        note: "Grocery Shopping",
        type: .expense,
        accountId: accountId
    )

    static let monthlyBudget = Budget(
        name: "Monthly Budget",
        period: .monthly,
        totalLimit: Decimal(string: "2000.00")!,
        userId: userId
    )

    static let portfolio = Portfolio(
        id: portfolioId,
        name: "Retirement Fund",
        userId: userId,
        investments: [sampleInvestment]
    )

    static let sampleInvestment = Investment(
        assetType: .etf,
        name: "S&P 500 ETF",
        initialCapital: Decimal(string: "10000.00")!,
        monthlyContribution: Decimal(string: "500.00")!,
        expectedReturn: Decimal(string: "0.07")!,
        riskProfile: .medium,
        durationMonths: 120,
        portfolioId: portfolioId
    )

    static let sampleForecast = Forecast(
        name: "Base Scenario",
        projectionMonths: 12,
        monthlyProjections: (1...12).map { month in
            ForecastMonth(
                month: month,
                income: 3500,
                expenses: 2500,
                savings: Decimal(month) * 1000,
                investmentValue: Decimal(month) * 50,
                netWorth: Decimal(month) * 1050
            )
        },
        userId: userId
    )
}
