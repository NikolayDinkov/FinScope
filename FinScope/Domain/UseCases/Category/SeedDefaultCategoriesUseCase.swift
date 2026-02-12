import Foundation

struct SeedDefaultCategoriesUseCase: Sendable {
    private let categoryRepository: CategoryRepositoryProtocol
    private let subcategoryRepository: SubcategoryRepositoryProtocol

    init(
        categoryRepository: CategoryRepositoryProtocol,
        subcategoryRepository: SubcategoryRepositoryProtocol
    ) {
        self.categoryRepository = categoryRepository
        self.subcategoryRepository = subcategoryRepository
    }

    func execute() async throws {
        let defaults = DefaultCategoryData.allCategories
        try await categoryRepository.seedDefaultsIfNeeded(defaults: defaults)

        let existingCategories = try await categoryRepository.fetchAll()

        for categoryData in DefaultCategoryData.categoriesWithSubcategories {
            guard let category = existingCategories.first(where: { $0.name == categoryData.name }) else {
                continue
            }

            let existingSubcategories = try await subcategoryRepository.fetchAll(for: category.id)
            if existingSubcategories.isEmpty {
                for subcategory in categoryData.subcategories {
                    let sub = Subcategory(
                        categoryId: category.id,
                        name: subcategory,
                        isDefault: true
                    )
                    try await subcategoryRepository.create(sub)
                }
            }
        }
    }
}
