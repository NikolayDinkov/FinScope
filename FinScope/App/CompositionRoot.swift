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
}
