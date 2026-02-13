import Foundation
import CoreData

@MainActor
final class CompositionRoot {
    static let shared = CompositionRoot()

    let coreDataStack: CoreDataStack
    let accountRepository: AccountRepositoryProtocol
    let transactionRepository: TransactionRepositoryProtocol
    let categoryRepository: CategoryRepositoryProtocol
    let subcategoryRepository: SubcategoryRepositoryProtocol
    let budgetRepository: BudgetRepositoryProtocol
    let forecastService: ForecastServiceProtocol
    let portfolioRepository: PortfolioRepositoryProtocol
    let marketService: MarketSimulatorServiceProtocol

    private init() {
        coreDataStack = CoreDataStack()
        let context = coreDataStack.viewContext

        accountRepository = CoreDataAccountRepository(context: context)
        transactionRepository = CoreDataTransactionRepository(context: context)
        categoryRepository = CoreDataCategoryRepository(context: context)
        subcategoryRepository = CoreDataSubcategoryRepository(context: context)
        budgetRepository = CoreDataBudgetRepository(context: context)
        forecastService = ForecastService()
        portfolioRepository = CoreDataPortfolioRepository(context: context)
        marketService = MarketSimulatorService()
    }

    func seedDefaultCategories() async {
        let useCase = SeedDefaultCategoriesUseCase(
            categoryRepository: categoryRepository,
            subcategoryRepository: subcategoryRepository
        )
        try? await useCase.execute()
    }

    func seedDummyDataIfNeeded() async {
        do {
            let existingAccounts = try await accountRepository.fetchAll()
            guard existingAccounts.isEmpty else { return }

            // -- Accounts --
            let checking = Account(name: "Checking Account", type: .bank, currencyCode: "USD", balance: 4250.75)
            let savings = Account(name: "Savings Account", type: .bank, currencyCode: "USD", balance: 12800.00)
            let cash = Account(name: "Cash Wallet", type: .cash, currencyCode: "USD", balance: 340.50)
            let euroAccount = Account(name: "Euro Account", type: .bank, currencyCode: "EUR", balance: 2150.00)

            for account in [checking, savings, cash, euroAccount] {
                try await accountRepository.create(account)
            }

            // -- Categories lookup --
            let categories = try await categoryRepository.fetchAll()
            func categoryId(named name: String) -> UUID? {
                categories.first(where: { $0.name == name })?.id
            }

            // -- Transactions (last 60 days spread) --
            let calendar = Calendar.current
            let now = Date()

            let transactions: [(UUID, TransactionType, Decimal, String, String?, Int)] = [
                // accountId, type, amount, note, categoryName, daysAgo
                (checking.id, .income, 3500, "Monthly salary", "Salary", 30),
                (checking.id, .income, 3500, "Monthly salary", "Salary", 0),
                (checking.id, .expense, 1200, "Rent payment", "Housing", 28),
                (checking.id, .expense, 1200, "Rent payment", "Housing", 0),
                (checking.id, .expense, 85.50, "Grocery store", "Food & Dining", 25),
                (checking.id, .expense, 120.30, "Weekly groceries", "Food & Dining", 18),
                (checking.id, .expense, 95.20, "Grocery run", "Food & Dining", 11),
                (checking.id, .expense, 110.00, "Groceries", "Food & Dining", 4),
                (checking.id, .expense, 45.00, "Gas station", "Transport", 22),
                (checking.id, .expense, 52.00, "Gas fill-up", "Transport", 8),
                (checking.id, .expense, 14.99, "Netflix", "Entertainment", 20),
                (checking.id, .expense, 9.99, "Spotify", "Entertainment", 20),
                (checking.id, .expense, 65.00, "Electric bill", "Utilities", 15),
                (checking.id, .expense, 49.99, "Internet bill", "Utilities", 15),
                (checking.id, .expense, 35.00, "Phone bill", "Utilities", 15),
                (checking.id, .expense, 150.00, "New shoes", "Shopping", 12),
                (checking.id, .expense, 30.00, "Copay", "Healthcare", 7),
                (savings.id, .income, 500, "Freelance project", "Freelance", 14),
                (savings.id, .income, 75, "Dividend payout", "Investment Income", 10),
                (cash.id, .expense, 28.50, "Coffee & lunch", "Food & Dining", 3),
                (cash.id, .expense, 42.00, "Taxi ride", "Transport", 6),
                (cash.id, .expense, 15.00, "Movie ticket", "Entertainment", 9),
                (euroAccount.id, .expense, 85.00, "Restaurant dinner", "Food & Dining", 5),
                (euroAccount.id, .expense, 120.00, "Online course", "Education", 2),
            ]

            for (accountId, type, amount, note, catName, daysAgo) in transactions {
                let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
                let transaction = Transaction(
                    accountId: accountId,
                    type: type,
                    amount: amount,
                    categoryId: catName.flatMap { categoryId(named: $0) },
                    note: note,
                    date: date
                )
                try await transactionRepository.create(transaction)
            }

            // -- Budgets (monthly limits for expense categories) --
            let budgetData: [(String, Decimal)] = [
                ("Food & Dining", 500),
                ("Transport", 150),
                ("Housing", 1300),
                ("Entertainment", 100),
                ("Utilities", 200),
                ("Shopping", 200),
                ("Healthcare", 100),
                ("Education", 150),
            ]

            for (catName, amount) in budgetData {
                guard let catId = categoryId(named: catName) else { continue }
                let budget = Budget(categoryId: catId, amount: amount)
                try await budgetRepository.create(budget)
            }

        } catch {
            print("Failed to seed dummy data: \(error)")
        }
    }
}
