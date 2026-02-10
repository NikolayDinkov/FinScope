import Foundation

@MainActor @Observable
final class TransactionFormViewModel {
    private let addTransaction: AddTransactionUseCase
    private let fetchAccounts: FetchAccountsUseCase

    let editingTransaction: Transaction?
    var amount: String
    var type: TransactionType
    var date: Date
    var note: String
    var isRecurring: Bool
    var recurringInterval: RecurringInterval
    var accounts: [Account] = []
    var selectedAccountId: UUID?
    var errorMessage: String?
    var didSave = false

    var isEditing: Bool { editingTransaction != nil }

    init(transaction: Transaction?, addTransaction: AddTransactionUseCase, fetchAccounts: FetchAccountsUseCase) {
        self.editingTransaction = transaction
        self.addTransaction = addTransaction
        self.fetchAccounts = fetchAccounts
        self.amount = transaction.map { "\($0.amount)" } ?? ""
        self.type = transaction?.type ?? .expense
        self.date = transaction?.date ?? Date()
        self.note = transaction?.note ?? ""
        self.isRecurring = transaction?.isRecurring ?? false
        self.recurringInterval = transaction?.recurringInterval ?? .monthly
        self.selectedAccountId = transaction?.accountId
    }

    func loadAccounts() async {
        do {
            accounts = try await fetchAccounts.executeAll()
            if selectedAccountId == nil {
                selectedAccountId = accounts.first?.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() async {
        guard let decimalAmount = Decimal(string: amount), decimalAmount > 0 else {
            errorMessage = "Please enter a valid amount"
            return
        }
        guard let accountId = selectedAccountId,
              let account = accounts.first(where: { $0.id == accountId }) else {
            errorMessage = "Please select an account"
            return
        }

        let transaction = Transaction(
            id: editingTransaction?.id ?? UUID(),
            amount: decimalAmount,
            date: date,
            note: note.nilIfEmpty,
            isRecurring: isRecurring,
            recurringInterval: isRecurring ? recurringInterval : nil,
            type: type,
            accountId: accountId
        )

        do {
            try await addTransaction.execute(transaction, account: account)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
