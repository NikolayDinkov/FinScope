import CoreData

protocol ManagedObjectMapper {
    associatedtype Entity
    associatedtype MO: NSManagedObject

    func toEntity(_ mo: MO) -> Entity
    func toManagedObject(_ entity: Entity, in context: NSManagedObjectContext) -> MO
    func update(_ mo: MO, from entity: Entity)
}

// MARK: - User Mapper

struct UserMapper: ManagedObjectMapper {
    func toEntity(_ mo: UserMO) -> User {
        User(
            id: mo.id,
            name: mo.name,
            email: mo.email,
            createdAt: mo.createdAt
        )
    }

    func toManagedObject(_ entity: User, in context: NSManagedObjectContext) -> UserMO {
        let mo = UserMO(context: context)
        mo.id = entity.id
        update(mo, from: entity)
        return mo
    }

    func update(_ mo: UserMO, from entity: User) {
        mo.name = entity.name
        mo.email = entity.email
        mo.createdAt = entity.createdAt
    }
}

// MARK: - Account Mapper

struct AccountMapper: ManagedObjectMapper {
    func toEntity(_ mo: AccountMO) -> Account {
        Account(
            id: mo.id,
            name: mo.name,
            type: AccountType(rawValue: mo.type) ?? .cash,
            currency: mo.currency,
            createdAt: mo.createdAt,
            userId: mo.user?.id ?? UUID()
        )
    }

    func toManagedObject(_ entity: Account, in context: NSManagedObjectContext) -> AccountMO {
        let mo = AccountMO(context: context)
        mo.id = entity.id
        update(mo, from: entity)
        return mo
    }

    func update(_ mo: AccountMO, from entity: Account) {
        mo.name = entity.name
        mo.type = entity.type.rawValue
        mo.currency = entity.currency
        mo.createdAt = entity.createdAt
    }
}

// MARK: - Transaction Mapper

struct TransactionMapper: ManagedObjectMapper {
    func toEntity(_ mo: TransactionMO) -> Transaction {
        Transaction(
            id: mo.id,
            amount: mo.amount.decimalValue,
            originalAmount: mo.originalAmount?.decimalValue,
            originalCurrency: mo.originalCurrency,
            date: mo.date,
            note: mo.note,
            isRecurring: mo.isRecurring,
            recurringInterval: mo.recurringInterval.flatMap { RecurringInterval(rawValue: $0) },
            type: TransactionType(rawValue: mo.type) ?? .expense,
            createdAt: mo.createdAt,
            accountId: mo.account?.id ?? UUID(),
            categoryId: mo.category?.id
        )
    }

    func toManagedObject(_ entity: Transaction, in context: NSManagedObjectContext) -> TransactionMO {
        let mo = TransactionMO(context: context)
        mo.id = entity.id
        update(mo, from: entity)
        return mo
    }

    func update(_ mo: TransactionMO, from entity: Transaction) {
        mo.amount = NSDecimalNumber(decimal: entity.amount)
        mo.originalAmount = entity.originalAmount.map { NSDecimalNumber(decimal: $0) }
        mo.originalCurrency = entity.originalCurrency
        mo.date = entity.date
        mo.note = entity.note
        mo.isRecurring = entity.isRecurring
        mo.recurringInterval = entity.recurringInterval?.rawValue
        mo.type = entity.type.rawValue
        mo.createdAt = entity.createdAt
    }
}

// MARK: - Category Mapper

struct CategoryMapper: ManagedObjectMapper {
    func toEntity(_ mo: CategoryMO) -> Category {
        Category(
            id: mo.id,
            name: mo.name,
            icon: mo.icon,
            type: TransactionType(rawValue: mo.type) ?? .expense,
            parentId: mo.parent?.id
        )
    }

    func toManagedObject(_ entity: Category, in context: NSManagedObjectContext) -> CategoryMO {
        let mo = CategoryMO(context: context)
        mo.id = entity.id
        update(mo, from: entity)
        return mo
    }

    func update(_ mo: CategoryMO, from entity: Category) {
        mo.name = entity.name
        mo.icon = entity.icon
        mo.type = entity.type.rawValue
    }
}

// MARK: - Budget Mapper

struct BudgetMapper: ManagedObjectMapper {
    private let ruleMapper = BudgetRuleMapper()

    func toEntity(_ mo: BudgetMO) -> Budget {
        let rules = (mo.rules?.allObjects as? [BudgetRuleMO])?.map { ruleMapper.toEntity($0) } ?? []
        return Budget(
            id: mo.id,
            name: mo.name,
            period: BudgetPeriod(rawValue: mo.period) ?? .monthly,
            startDate: mo.startDate,
            endDate: mo.endDate,
            totalLimit: mo.totalLimit?.decimalValue,
            userId: mo.user?.id ?? UUID(),
            rules: rules
        )
    }

    func toManagedObject(_ entity: Budget, in context: NSManagedObjectContext) -> BudgetMO {
        let mo = BudgetMO(context: context)
        mo.id = entity.id
        update(mo, from: entity)

        let ruleMOs = entity.rules.map { rule -> BudgetRuleMO in
            let ruleMO = ruleMapper.toManagedObject(rule, in: context)
            ruleMO.budget = mo
            return ruleMO
        }
        mo.rules = NSSet(array: ruleMOs)

        return mo
    }

    func update(_ mo: BudgetMO, from entity: Budget) {
        mo.name = entity.name
        mo.period = entity.period.rawValue
        mo.startDate = entity.startDate
        mo.endDate = entity.endDate
        mo.totalLimit = entity.totalLimit.map { NSDecimalNumber(decimal: $0) }
    }
}

// MARK: - BudgetRule Mapper

struct BudgetRuleMapper: ManagedObjectMapper {
    func toEntity(_ mo: BudgetRuleMO) -> BudgetRule {
        BudgetRule(
            id: mo.id,
            ruleType: BudgetRuleType(rawValue: mo.ruleType) ?? .fixedLimit,
            limitAmount: mo.limitAmount?.decimalValue,
            percentage: mo.percentage?.decimalValue,
            budgetId: mo.budget?.id ?? UUID(),
            categoryId: mo.category?.id ?? UUID()
        )
    }

    func toManagedObject(_ entity: BudgetRule, in context: NSManagedObjectContext) -> BudgetRuleMO {
        let mo = BudgetRuleMO(context: context)
        mo.id = entity.id
        update(mo, from: entity)
        return mo
    }

    func update(_ mo: BudgetRuleMO, from entity: BudgetRule) {
        mo.ruleType = entity.ruleType.rawValue
        mo.limitAmount = entity.limitAmount.map { NSDecimalNumber(decimal: $0) }
        mo.percentage = entity.percentage.map { NSDecimalNumber(decimal: $0) }
    }
}

// MARK: - Portfolio Mapper

struct PortfolioMapper: ManagedObjectMapper {
    private let investmentMapper = InvestmentMapper()

    func toEntity(_ mo: PortfolioMO) -> Portfolio {
        let investments = (mo.investments?.allObjects as? [InvestmentMO])?.map { investmentMapper.toEntity($0) } ?? []
        return Portfolio(
            id: mo.id,
            name: mo.name,
            createdAt: mo.createdAt,
            userId: mo.user?.id ?? UUID(),
            investments: investments
        )
    }

    func toManagedObject(_ entity: Portfolio, in context: NSManagedObjectContext) -> PortfolioMO {
        let mo = PortfolioMO(context: context)
        mo.id = entity.id
        update(mo, from: entity)

        let investmentMOs = entity.investments.map { investment -> InvestmentMO in
            let invMO = investmentMapper.toManagedObject(investment, in: context)
            invMO.portfolio = mo
            return invMO
        }
        mo.investments = NSSet(array: investmentMOs)

        return mo
    }

    func update(_ mo: PortfolioMO, from entity: Portfolio) {
        mo.name = entity.name
        mo.createdAt = entity.createdAt
    }
}

// MARK: - Investment Mapper

struct InvestmentMapper: ManagedObjectMapper {
    func toEntity(_ mo: InvestmentMO) -> Investment {
        Investment(
            id: mo.id,
            assetType: AssetType(rawValue: mo.assetType) ?? .stock,
            name: mo.name,
            initialCapital: mo.initialCapital.decimalValue,
            monthlyContribution: mo.monthlyContribution.decimalValue,
            expectedReturn: mo.expectedReturn.decimalValue,
            riskProfile: RiskProfile(rawValue: mo.riskProfile) ?? .medium,
            taxRate: mo.taxRate.decimalValue,
            inflationRate: mo.inflationRate.decimalValue,
            startDate: mo.startDate,
            durationMonths: Int(mo.durationMonths),
            portfolioId: mo.portfolio?.id ?? UUID()
        )
    }

    func toManagedObject(_ entity: Investment, in context: NSManagedObjectContext) -> InvestmentMO {
        let mo = InvestmentMO(context: context)
        mo.id = entity.id
        update(mo, from: entity)
        return mo
    }

    func update(_ mo: InvestmentMO, from entity: Investment) {
        mo.assetType = entity.assetType.rawValue
        mo.name = entity.name
        mo.initialCapital = NSDecimalNumber(decimal: entity.initialCapital)
        mo.monthlyContribution = NSDecimalNumber(decimal: entity.monthlyContribution)
        mo.expectedReturn = NSDecimalNumber(decimal: entity.expectedReturn)
        mo.riskProfile = entity.riskProfile.rawValue
        mo.taxRate = NSDecimalNumber(decimal: entity.taxRate)
        mo.inflationRate = NSDecimalNumber(decimal: entity.inflationRate)
        mo.startDate = entity.startDate
        mo.durationMonths = Int32(entity.durationMonths)
    }
}

// MARK: - Forecast Mapper

struct ForecastMapper: ManagedObjectMapper {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func toEntity(_ mo: ForecastMO) -> Forecast {
        let projections = (try? decoder.decode([ForecastMonth].self, from: Data(mo.resultJSON.utf8))) ?? []
        return Forecast(
            id: mo.id,
            name: mo.name,
            createdAt: mo.createdAt,
            projectionMonths: Int(mo.projectionMonths),
            monthlyProjections: projections,
            userId: mo.user?.id ?? UUID()
        )
    }

    func toManagedObject(_ entity: Forecast, in context: NSManagedObjectContext) -> ForecastMO {
        let mo = ForecastMO(context: context)
        mo.id = entity.id
        update(mo, from: entity)
        return mo
    }

    func update(_ mo: ForecastMO, from entity: Forecast) {
        mo.name = entity.name
        mo.createdAt = entity.createdAt
        mo.projectionMonths = Int32(entity.projectionMonths)
        mo.resultJSON = (try? String(data: encoder.encode(entity.monthlyProjections), encoding: .utf8)) ?? "[]"
    }
}
