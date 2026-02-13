import Foundation

@MainActor @Observable
final class BudgetFormViewModel {
    var selectedCategoryId: UUID?
    var amountText: String = ""
    var categories: [Category] = []
    var existingBudgetCategoryIds: Set<UUID> = []
    var errorMessage: String?

    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?

    let isEditing: Bool
    private let editingBudgetId: UUID?
    private let editingCategoryId: UUID?
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let fetchBudgetsUseCase: FetchBudgetsUseCase
    private let createBudgetUseCase: CreateBudgetUseCase
    private let updateBudgetUseCase: UpdateBudgetUseCase

    init(
        editingBudget: Budget? = nil,
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        fetchBudgetsUseCase: FetchBudgetsUseCase,
        createBudgetUseCase: CreateBudgetUseCase,
        updateBudgetUseCase: UpdateBudgetUseCase
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.fetchBudgetsUseCase = fetchBudgetsUseCase
        self.createBudgetUseCase = createBudgetUseCase
        self.updateBudgetUseCase = updateBudgetUseCase

        if let editingBudget {
            self.isEditing = true
            self.editingBudgetId = editingBudget.id
            self.editingCategoryId = editingBudget.categoryId
            self.selectedCategoryId = editingBudget.categoryId
            self.amountText = "\(editingBudget.amount)"
        } else {
            self.isEditing = false
            self.editingBudgetId = nil
            self.editingCategoryId = nil
        }
    }

    var availableCategories: [Category] {
        categories.filter { category in
            category.id == editingCategoryId || !existingBudgetCategoryIds.contains(category.id)
        }
    }

    var isValid: Bool {
        selectedCategoryId != nil && (Decimal(string: amountText) ?? 0) > 0
    }

    func load() async {
        do {
            categories = try await fetchCategoriesUseCase.execute(type: .expense)
            let budgets = try await fetchBudgetsUseCase.execute()
            existingBudgetCategoryIds = Set(budgets.map(\.categoryId))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() async {
        guard let categoryId = selectedCategoryId,
              let amount = Decimal(string: amountText), amount > 0 else { return }

        do {
            if isEditing, let budgetId = editingBudgetId {
                let budget = Budget(
                    id: budgetId,
                    categoryId: categoryId,
                    amount: amount
                )
                try await updateBudgetUseCase.execute(budget)
            } else {
                let budget = Budget(
                    categoryId: categoryId,
                    amount: amount
                )
                try await createBudgetUseCase.execute(budget)
            }
            onSave?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
