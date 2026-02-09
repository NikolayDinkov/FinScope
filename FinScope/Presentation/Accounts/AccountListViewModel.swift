import Foundation

@Observable
final class AccountListViewModel {
    private let fetchAccounts: FetchAccountsUseCase
    private let deleteAccount: DeleteAccountUseCase

    var accounts: [Account] = []
    var errorMessage: String?
    var showDeleteError = false

    init(fetchAccounts: FetchAccountsUseCase, deleteAccount: DeleteAccountUseCase) {
        self.fetchAccounts = fetchAccounts
        self.deleteAccount = deleteAccount
    }

    func load() async {
        do {
            accounts = try await fetchAccounts.executeAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ account: Account) async {
        do {
            try await deleteAccount.execute(account)
            accounts.removeAll { $0.id == account.id }
        } catch {
            errorMessage = error.localizedDescription
            showDeleteError = true
        }
    }
}
