import Testing
import CoreData
@testable import FinScope

@Suite("ManagedObject Mapper Tests")
struct MapperTests {

    private func makeInMemoryContext() -> NSManagedObjectContext {
        let stack = CoreDataStack(modelName: "FinScope", inMemory: true)
        return stack.viewContext
    }

    // MARK: - User Mapper

    @Test("UserMapper round-trip")
    func userMapperRoundTrip() {
        let context = makeInMemoryContext()
        let mapper = UserMapper()

        let user = User(name: "Test User", email: "test@example.com")
        let mo = mapper.toManagedObject(user, in: context)
        let result = mapper.toEntity(mo)

        #expect(result.id == user.id)
        #expect(result.name == user.name)
        #expect(result.email == user.email)
    }

    // MARK: - Account Mapper

    @Test("AccountMapper round-trip")
    func accountMapperRoundTrip() {
        let context = makeInMemoryContext()
        let mapper = AccountMapper()

        let account = Account(name: "Savings", type: .bank, currency: "EUR", userId: UUID())
        let mo = mapper.toManagedObject(account, in: context)
        let result = mapper.toEntity(mo)

        #expect(result.id == account.id)
        #expect(result.name == "Savings")
        #expect(result.type == .bank)
        #expect(result.currency == "EUR")
    }

    // MARK: - Transaction Mapper

    @Test("TransactionMapper round-trip preserves amounts")
    func transactionMapperRoundTrip() {
        let context = makeInMemoryContext()
        let mapper = TransactionMapper()

        let tx = Transaction(
            amount: Decimal(string: "123.45")!,
            originalAmount: Decimal(string: "100.00")!,
            originalCurrency: "USD",
            note: "Test note",
            isRecurring: true,
            recurringInterval: .monthly,
            type: .expense,
            accountId: UUID()
        )
        let mo = mapper.toManagedObject(tx, in: context)
        let result = mapper.toEntity(mo)

        #expect(result.id == tx.id)
        #expect(result.amount == Decimal(string: "123.45")!)
        #expect(result.originalAmount == Decimal(string: "100.00")!)
        #expect(result.originalCurrency == "USD")
        #expect(result.isRecurring == true)
        #expect(result.recurringInterval == .monthly)
        #expect(result.type == .expense)
    }

    // MARK: - Investment Mapper

    @Test("InvestmentMapper round-trip preserves decimal precision")
    func investmentMapperRoundTrip() {
        let context = makeInMemoryContext()
        let mapper = InvestmentMapper()

        let investment = Investment(
            assetType: .etf,
            name: "VOO",
            initialCapital: Decimal(string: "50000.00")!,
            monthlyContribution: Decimal(string: "1000.00")!,
            expectedReturn: Decimal(string: "0.07")!,
            riskProfile: .medium,
            taxRate: Decimal(string: "0.10")!,
            inflationRate: Decimal(string: "0.03")!,
            durationMonths: 120,
            portfolioId: UUID()
        )
        let mo = mapper.toManagedObject(investment, in: context)
        let result = mapper.toEntity(mo)

        #expect(result.initialCapital == Decimal(string: "50000.00")!)
        #expect(result.expectedReturn == Decimal(string: "0.07")!)
        #expect(result.taxRate == Decimal(string: "0.10")!)
        #expect(result.durationMonths == 120)
    }

    // MARK: - Category Mapper

    @Test("CategoryMapper round-trip")
    func categoryMapperRoundTrip() {
        let context = makeInMemoryContext()
        let mapper = CategoryMapper()

        let category = Category(name: "Food", icon: "fork.knife", type: .expense)
        let mo = mapper.toManagedObject(category, in: context)
        let result = mapper.toEntity(mo)

        #expect(result.name == "Food")
        #expect(result.icon == "fork.knife")
        #expect(result.type == .expense)
    }
}
