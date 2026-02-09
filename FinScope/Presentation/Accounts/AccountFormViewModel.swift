import Foundation

@Observable
final class AccountFormViewModel {
    private let createAccount: CreateAccountUseCase
    private let accountRepository: any AccountRepositoryProtocol

    let editingAccount: Account?
    var name: String
    var selectedType: AccountType
    var currency: String
    var errorMessage: String?
    var didSave = false

    var isEditing: Bool { editingAccount != nil }

    init(account: Account?, createAccount: CreateAccountUseCase, accountRepository: any AccountRepositoryProtocol) {
        self.editingAccount = account
        self.createAccount = createAccount
        self.accountRepository = accountRepository
        self.name = account?.name ?? ""
        self.selectedType = account?.type ?? .bank
        self.currency = account?.currency ?? "BGN"
    }

    func save(userId: UUID) async {
        do {
            if let existing = editingAccount {
                var updated = existing
                updated.name = name.trimmed
                updated.type = selectedType
                updated.currency = currency
                try await accountRepository.save(updated)
            } else {
                _ = try await createAccount.execute(
                    name: name,
                    type: selectedType,
                    currency: currency,
                    userId: userId
                )
            }
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
