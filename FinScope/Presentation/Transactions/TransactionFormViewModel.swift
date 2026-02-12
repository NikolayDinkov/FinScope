import Foundation

@MainActor @Observable
final class TransactionFormViewModel {
    var selectedType: TransactionType = .expense
    var amountText = ""
    var note = ""
    var selectedDate = Date()
    var selectedCategoryId: UUID?
    var selectedSubcategoryId: UUID?
    var isRecurring = false
    var selectedFrequency: RecurrenceFrequency = .monthly
    var recurrenceEndDate: Date?
    var errorMessage: String?

    var categories: [Category] = []
    var subcategories: [Subcategory] = []

    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?

    private let accountId: UUID
    private let transactionId: UUID?
    private let fetchTransactionsUseCase: FetchTransactionsUseCase
    private let addTransactionUseCase: AddTransactionUseCase
    private let updateTransactionUseCase: UpdateTransactionUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let subcategoryRepository: SubcategoryRepositoryProtocol

    init(
        accountId: UUID,
        transactionId: UUID?,
        fetchTransactionsUseCase: FetchTransactionsUseCase,
        addTransactionUseCase: AddTransactionUseCase,
        updateTransactionUseCase: UpdateTransactionUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        subcategoryRepository: SubcategoryRepositoryProtocol
    ) {
        self.accountId = accountId
        self.transactionId = transactionId
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
        self.addTransactionUseCase = addTransactionUseCase
        self.updateTransactionUseCase = updateTransactionUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.subcategoryRepository = subcategoryRepository
    }

    var isEditing: Bool { transactionId != nil }

    var isValid: Bool {
        guard let amount = Decimal(string: amountText), amount > 0 else { return false }
        return selectedCategoryId != nil
    }

    var filteredCategories: [Category] {
        categories.filter { $0.transactionType == selectedType }
    }

    func load() async {
        do {
            categories = try await fetchCategoriesUseCase.execute()

            if let transactionId,
               let transactions = try? await fetchTransactionsUseCase.execute(for: accountId),
               let existing = transactions.first(where: { $0.id == transactionId }) {
                selectedType = existing.type
                amountText = "\(existing.amount)"
                note = existing.note
                selectedDate = existing.date
                selectedCategoryId = existing.categoryId
                selectedSubcategoryId = existing.subcategoryId
                isRecurring = existing.isRecurring
                if let rule = existing.recurrenceRule {
                    selectedFrequency = rule.frequency
                    recurrenceEndDate = rule.endDate
                }
            }

            if let categoryId = selectedCategoryId {
                subcategories = try await subcategoryRepository.fetchAll(for: categoryId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadSubcategories() async {
        guard let categoryId = selectedCategoryId else {
            subcategories = []
            return
        }
        subcategories = (try? await subcategoryRepository.fetchAll(for: categoryId)) ?? []
        selectedSubcategoryId = nil
    }

    func save() async {
        guard let amount = Decimal(string: amountText), amount > 0,
              let categoryId = selectedCategoryId else {
            errorMessage = "Please enter a valid amount and select a category."
            return
        }

        let recurrenceRule: RecurrenceRule? = isRecurring
            ? RecurrenceRule(
                frequency: selectedFrequency,
                startDate: selectedDate,
                endDate: recurrenceEndDate
            )
            : nil

        do {
            if let transactionId {
                let transaction = Transaction(
                    id: transactionId,
                    accountId: accountId,
                    type: selectedType,
                    amount: amount,
                    categoryId: categoryId,
                    subcategoryId: selectedSubcategoryId,
                    note: note,
                    date: selectedDate,
                    isRecurring: isRecurring,
                    recurrenceRule: recurrenceRule
                )
                try await updateTransactionUseCase.execute(transaction)
            } else {
                let transaction = Transaction(
                    accountId: accountId,
                    type: selectedType,
                    amount: amount,
                    categoryId: categoryId,
                    subcategoryId: selectedSubcategoryId,
                    note: note,
                    date: selectedDate,
                    isRecurring: isRecurring,
                    recurrenceRule: recurrenceRule
                )
                try await addTransactionUseCase.execute(transaction)
            }
            onSave?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
