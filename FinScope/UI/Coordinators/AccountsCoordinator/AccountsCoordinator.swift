import SwiftUI

@MainActor
final class AccountsCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()
    @Published var sheet: AccountsSheet?

    enum AccountsSheet: Identifiable {
        case accountForm(accountId: UUID?)
        case transactionForm(accountId: UUID, transactionId: UUID?)
        case csvImportExport(accountId: UUID)
        case categoryManagement
        case categoryForm

        var id: String {
            switch self {
            case .accountForm(let id): "accountForm-\(id?.uuidString ?? "new")"
            case .transactionForm(let aid, let tid): "txForm-\(aid)-\(tid?.uuidString ?? "new")"
            case .csvImportExport(let id): "csv-\(id)"
            case .categoryManagement: "categories"
            case .categoryForm: "categoryForm"
            }
        }
    }

    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol
    private let subcategoryRepository: SubcategoryRepositoryProtocol

    init(
        accountRepository: AccountRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol,
        categoryRepository: CategoryRepositoryProtocol,
        subcategoryRepository: SubcategoryRepositoryProtocol
    ) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.categoryRepository = categoryRepository
        self.subcategoryRepository = subcategoryRepository
    }

    private(set) lazy var accountListViewModel: AccountListViewModel = makeAccountListViewModel()
    private var accountDetailViewModels: [UUID: AccountDetailViewModel] = [:]

    func start() -> some View {
        AccountsCoordinatorView(coordinator: self)
    }

    // MARK: - View Model Factories

    private func makeAccountListViewModel() -> AccountListViewModel {
        let vm = AccountListViewModel(
            fetchAccountsUseCase: FetchAccountsUseCase(repository: accountRepository),
            deleteAccountUseCase: DeleteAccountUseCase(repository: accountRepository)
        )
        vm.onAddAccount = { [weak self] in
            self?.sheet = .accountForm(accountId: nil)
        }
        vm.onSelectAccount = { [weak self] id in
            self?.path.append(.accountDetail(accountId: id))
        }
        return vm
    }

    func accountDetailViewModel(for accountId: UUID) -> AccountDetailViewModel {
        if let cached = accountDetailViewModels[accountId] {
            return cached
        }
        let vm = AccountDetailViewModel(
            accountId: accountId,
            fetchAccountUseCase: FetchAccountUseCase(repository: accountRepository),
            fetchTransactionsUseCase: FetchTransactionsUseCase(repository: transactionRepository),
            fetchCategoriesUseCase: FetchCategoriesUseCase(repository: categoryRepository),
            deleteTransactionUseCase: DeleteTransactionUseCase(
                transactionRepository: transactionRepository,
                accountRepository: accountRepository
            )
        )
        vm.onEditAccount = { [weak self] in
            self?.sheet = .accountForm(accountId: accountId)
        }
        vm.onAddTransaction = { [weak self] in
            self?.sheet = .transactionForm(accountId: accountId, transactionId: nil)
        }
        accountDetailViewModels[accountId] = vm
        return vm
    }

    func makeAccountFormViewModel(accountId: UUID?) -> AccountFormViewModel {
        let vm = AccountFormViewModel(
            accountId: accountId,
            fetchAccountUseCase: FetchAccountUseCase(repository: accountRepository),
            createAccountUseCase: CreateAccountUseCase(repository: accountRepository),
            updateAccountUseCase: UpdateAccountUseCase(repository: accountRepository)
        )
        vm.onSave = { [weak self] in self?.sheet = nil }
        vm.onCancel = { [weak self] in self?.sheet = nil }
        return vm
    }

    func makeTransactionFormViewModel(accountId: UUID, transactionId: UUID?) -> TransactionFormViewModel {
        let vm = TransactionFormViewModel(
            accountId: accountId,
            transactionId: transactionId,
            fetchTransactionsUseCase: FetchTransactionsUseCase(repository: transactionRepository),
            addTransactionUseCase: AddTransactionUseCase(
                transactionRepository: transactionRepository,
                accountRepository: accountRepository
            ),
            updateTransactionUseCase: UpdateTransactionUseCase(
                transactionRepository: transactionRepository,
                accountRepository: accountRepository
            ),
            fetchCategoriesUseCase: FetchCategoriesUseCase(repository: categoryRepository),
            subcategoryRepository: subcategoryRepository
        )
        vm.onSave = { [weak self] in self?.sheet = nil }
        vm.onCancel = { [weak self] in self?.sheet = nil }
        return vm
    }

    func makeCSVImportExportViewModel(accountId: UUID) -> CSVImportExportViewModel {
        let vm = CSVImportExportViewModel(
            accountId: accountId,
            importUseCase: ImportTransactionsUseCase(
                transactionRepository: transactionRepository,
                accountRepository: accountRepository,
                categoryRepository: categoryRepository
            ),
            exportUseCase: ExportTransactionsUseCase(
                transactionRepository: transactionRepository,
                categoryRepository: categoryRepository
            )
        )
        vm.onDismiss = { [weak self] in self?.sheet = nil }
        return vm
    }

    func makeCategoryListViewModel() -> CategoryListViewModel {
        let vm = CategoryListViewModel(
            fetchCategoriesUseCase: FetchCategoriesUseCase(repository: categoryRepository)
        )
        vm.onAddCategory = { [weak self] in
            self?.sheet = .categoryForm
        }
        vm.onDismiss = { [weak self] in self?.sheet = nil }
        return vm
    }

    func createCategory(_ category: Category) async {
        let useCase = CreateCategoryUseCase(repository: categoryRepository)
        try? await useCase.execute(category)
        sheet = nil
    }
}
