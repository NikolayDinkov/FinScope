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

    private init() {
        coreDataStack = CoreDataStack()
        let context = coreDataStack.viewContext

        accountRepository = CoreDataAccountRepository(context: context)
        transactionRepository = CoreDataTransactionRepository(context: context)
        categoryRepository = CoreDataCategoryRepository(context: context)
        subcategoryRepository = CoreDataSubcategoryRepository(context: context)
    }

    func seedDefaultCategories() async {
        let useCase = SeedDefaultCategoriesUseCase(
            categoryRepository: categoryRepository,
            subcategoryRepository: subcategoryRepository
        )
        try? await useCase.execute()
    }
}
