import Foundation

@MainActor @Observable
final class CategoryListViewModel {
    var categories: [Category] = []
    var errorMessage: String?

    var onAddCategory: (() -> Void)?
    var onDismiss: (() -> Void)?

    private let fetchCategoriesUseCase: FetchCategoriesUseCase

    init(fetchCategoriesUseCase: FetchCategoriesUseCase) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
    }

    var incomeCategories: [Category] {
        categories.filter { $0.transactionType == .income }
    }

    var expenseCategories: [Category] {
        categories.filter { $0.transactionType == .expense }
    }

    func load() async {
        do {
            categories = try await fetchCategoriesUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
