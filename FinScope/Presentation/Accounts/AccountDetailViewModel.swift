import Foundation
import Combine

@MainActor @Observable
final class AccountDetailViewModel {
    var account: Account?
    var transactions: [Transaction] = []
    var categories: [Category] = []
    var errorMessage: String?
    var isLoading = false

    var onEditAccount: (() -> Void)?
    var onAddTransaction: (() -> Void)?
    var onBack: (() -> Void)?

    private let accountId: UUID
    private let fetchAccountUseCase: FetchAccountUseCase
    private let fetchTransactionsUseCase: FetchTransactionsUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let deleteTransactionUseCase: DeleteTransactionUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        accountId: UUID,
        fetchAccountUseCase: FetchAccountUseCase,
        fetchTransactionsUseCase: FetchTransactionsUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        deleteTransactionUseCase: DeleteTransactionUseCase
    ) {
        self.accountId = accountId
        self.fetchAccountUseCase = fetchAccountUseCase
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.deleteTransactionUseCase = deleteTransactionUseCase

        NotificationCenter.default.publisher(for: .accountsDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.load() }
            }
            .store(in: &cancellables)
    }

    func load() async {
        isLoading = true
        do {
            account = try await fetchAccountUseCase.execute(id: accountId)
            transactions = try await fetchTransactionsUseCase.execute(for: accountId)
            categories = try await fetchCategoriesUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteTransaction(id: UUID) async {
        do {
            try await deleteTransactionUseCase.execute(id: id)
            transactions.removeAll { $0.id == id }
            account = try await fetchAccountUseCase.execute(id: accountId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func categoryName(for id: UUID) -> String {
        categories.first { $0.id == id }?.name ?? ""
    }

    func categoryIcon(for id: UUID) -> String {
        categories.first { $0.id == id }?.icon ?? "circle.fill"
    }

    func categoryColorHex(for id: UUID) -> String {
        categories.first { $0.id == id }?.colorHex ?? "#007AFF"
    }
}
