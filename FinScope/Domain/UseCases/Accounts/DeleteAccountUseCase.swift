import Foundation

struct DeleteAccountUseCase: Sendable {
    private let accountRepository: any AccountRepositoryProtocol
    private let transactionRepository: any TransactionRepositoryProtocol

    init(accountRepository: any AccountRepositoryProtocol,
         transactionRepository: any TransactionRepositoryProtocol) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
    }

    func execute(_ account: Account) async throws {
        let transactionCount = try await transactionRepository.countByAccount(account.id)
        guard transactionCount == 0 else {
            throw AccountError.hasTransactions
        }
        try await accountRepository.delete(account)
    }
}
