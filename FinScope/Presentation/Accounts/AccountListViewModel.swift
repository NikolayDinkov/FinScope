import Foundation
import Combine

@MainActor @Observable
final class AccountListViewModel {
    var accounts: [Account] = []
    var errorMessage: String?
    var isLoading = false

    var onAddAccount: (() -> Void)?
    var onSelectAccount: ((UUID) -> Void)?

    private let fetchAccountsUseCase: FetchAccountsUseCase
    private let deleteAccountUseCase: DeleteAccountUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchAccountsUseCase: FetchAccountsUseCase,
        deleteAccountUseCase: DeleteAccountUseCase
    ) {
        self.fetchAccountsUseCase = fetchAccountsUseCase
        self.deleteAccountUseCase = deleteAccountUseCase

        NotificationCenter.default.publisher(for: .dataDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.loadAccounts() }
            }
            .store(in: &cancellables)
    }

    var groupedAccounts: [(AccountType, [Account])] {
        let grouped = Dictionary(grouping: accounts, by: \.type)
        return AccountType.allCases.compactMap { type in
            guard let accounts = grouped[type], !accounts.isEmpty else { return nil }
            return (type, accounts)
        }
    }

    func loadAccounts() async {
        isLoading = true
        errorMessage = nil
        do {
            accounts = try await fetchAccountsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteAccount(id: UUID) async {
        do {
            try await deleteAccountUseCase.execute(id: id)
            accounts.removeAll { $0.id == id }
        } catch let error as AccountDeletionError {
            switch error {
            case .accountHasTransactions:
                errorMessage = "Cannot delete account with existing transactions."
            case .accountNotFound:
                errorMessage = "Account not found."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
