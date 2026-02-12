import Foundation

@MainActor @Observable
final class AccountFormViewModel {
    var name = ""
    var selectedType: AccountType = .bank
    var selectedCurrency = "USD"
    var errorMessage: String?
    var isEditing: Bool

    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?

    private let accountId: UUID?
    private let fetchAccountUseCase: FetchAccountUseCase
    private let createAccountUseCase: CreateAccountUseCase
    private let updateAccountUseCase: UpdateAccountUseCase

    init(
        accountId: UUID?,
        fetchAccountUseCase: FetchAccountUseCase,
        createAccountUseCase: CreateAccountUseCase,
        updateAccountUseCase: UpdateAccountUseCase
    ) {
        self.accountId = accountId
        self.isEditing = accountId != nil
        self.fetchAccountUseCase = fetchAccountUseCase
        self.createAccountUseCase = createAccountUseCase
        self.updateAccountUseCase = updateAccountUseCase
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func load() async {
        guard let accountId, let account = try? await fetchAccountUseCase.execute(id: accountId) else {
            return
        }
        name = account.name
        selectedType = account.type
        selectedCurrency = account.currencyCode
    }

    func save() async {
        guard isValid else {
            errorMessage = "Account name cannot be empty."
            return
        }

        do {
            if let accountId, var existing = try await fetchAccountUseCase.execute(id: accountId) {
                existing.name = name
                existing.type = selectedType
                existing.currencyCode = selectedCurrency
                try await updateAccountUseCase.execute(existing)
            } else {
                let account = Account(
                    name: name.trimmingCharacters(in: .whitespaces),
                    type: selectedType,
                    currencyCode: selectedCurrency
                )
                try await createAccountUseCase.execute(account)
            }
            onSave?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
