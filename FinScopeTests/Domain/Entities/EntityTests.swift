import Testing
@testable import FinScope

@Suite("Domain Entity Tests")
struct EntityTests {

    // MARK: - User Tests

    @Test("User initializes with defaults")
    func userInit() {
        let user = User(name: "John")
        #expect(user.name == "John")
        #expect(user.email == nil)
        #expect(user.id != UUID())
    }

    @Test("User equality")
    func userEquality() {
        let id = UUID()
        let user1 = User(id: id, name: "John")
        let user2 = User(id: id, name: "John")
        #expect(user1 == user2)
    }

    // MARK: - Account Tests

    @Test("Account initializes with defaults")
    func accountInit() {
        let userId = UUID()
        let account = Account(name: "Savings", type: .bank, userId: userId)
        #expect(account.name == "Savings")
        #expect(account.type == .bank)
        #expect(account.currency == "BGN")
        #expect(account.userId == userId)
    }

    @Test("AccountType raw values")
    func accountTypeRawValues() {
        #expect(AccountType.cash.rawValue == "cash")
        #expect(AccountType.bank.rawValue == "bank")
        #expect(AccountType.investment.rawValue == "investment")
    }

    // MARK: - Transaction Tests

    @Test("Transaction initializes correctly")
    func transactionInit() {
        let accountId = UUID()
        let tx = Transaction(amount: 100, type: .income, accountId: accountId)
        #expect(tx.amount == 100)
        #expect(tx.type == .income)
        #expect(tx.isRecurring == false)
        #expect(tx.accountId == accountId)
    }

    @Test("TransactionType cases")
    func transactionTypes() {
        #expect(TransactionType.allCases.count == 2)
        #expect(TransactionType(rawValue: "income") == .income)
        #expect(TransactionType(rawValue: "expense") == .expense)
    }

    @Test("RecurringInterval cases")
    func recurringIntervals() {
        #expect(RecurringInterval.allCases.count == 4)
    }

    // MARK: - Category Tests

    @Test("Category with parent")
    func categoryParent() {
        let parentId = UUID()
        let category = Category(name: "Groceries", type: .expense, parentId: parentId)
        #expect(category.parentId == parentId)
        #expect(category.type == .expense)
    }

    // MARK: - Budget Tests

    @Test("Budget with rules")
    func budgetWithRules() {
        let userId = UUID()
        let budgetId = UUID()
        let rule = BudgetRule(
            ruleType: .fixedLimit,
            limitAmount: 500,
            budgetId: budgetId,
            categoryId: UUID()
        )
        let budget = Budget(
            id: budgetId,
            name: "Monthly",
            period: .monthly,
            totalLimit: 2000,
            userId: userId,
            rules: [rule]
        )
        #expect(budget.rules.count == 1)
        #expect(budget.totalLimit == 2000)
    }

    // MARK: - Investment Tests

    @Test("Investment initializes with defaults")
    func investmentInit() {
        let portfolioId = UUID()
        let inv = Investment(
            assetType: .etf,
            name: "S&P 500",
            initialCapital: 10000,
            expectedReturn: Decimal(string: "0.07")!,
            riskProfile: .medium,
            durationMonths: 120,
            portfolioId: portfolioId
        )
        #expect(inv.assetType == .etf)
        #expect(inv.monthlyContribution == 0)
        #expect(inv.taxRate == Decimal(string: "0.10")!)
        #expect(inv.inflationRate == Decimal(string: "0.03")!)
    }

    // MARK: - Portfolio Tests

    @Test("Portfolio with investments")
    func portfolioInit() {
        let userId = UUID()
        let portfolio = Portfolio(name: "Retirement", userId: userId)
        #expect(portfolio.investments.isEmpty)
        #expect(portfolio.name == "Retirement")
    }

    // MARK: - Forecast Tests

    @Test("ForecastMonth codable")
    func forecastMonthCodable() throws {
        let month = ForecastMonth(
            month: 1,
            income: 3000,
            expenses: 2000,
            savings: 1000,
            investmentValue: 500,
            netWorth: 1500
        )
        let data = try JSONEncoder().encode(month)
        let decoded = try JSONDecoder().decode(ForecastMonth.self, from: data)
        #expect(decoded == month)
    }
}
