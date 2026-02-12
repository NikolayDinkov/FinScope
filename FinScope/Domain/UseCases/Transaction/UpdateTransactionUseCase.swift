import Foundation

struct UpdateTransactionUseCase: Sendable {
    private let transactionRepository: TransactionRepositoryProtocol
    private let accountRepository: AccountRepositoryProtocol

    init(
        transactionRepository: TransactionRepositoryProtocol,
        accountRepository: AccountRepositoryProtocol
    ) {
        self.transactionRepository = transactionRepository
        self.accountRepository = accountRepository
    }

    func execute(_ transaction: Transaction) async throws {
        if let oldTransaction = try await transactionRepository.fetchById(transaction.id),
           var account = try await accountRepository.fetchById(transaction.accountId) {
            switch oldTransaction.type {
            case .income:
                account.balance -= oldTransaction.amount
            case .expense:
                account.balance += oldTransaction.amount
            case .transfer:
                account.balance += oldTransaction.amount
            }

            switch transaction.type {
            case .income:
                account.balance += transaction.amount
            case .expense:
                account.balance -= transaction.amount
            case .transfer:
                account.balance -= transaction.amount
            }

            account.updatedAt = Date()
            try await accountRepository.update(account)
        }

        var updated = transaction
        updated.updatedAt = Date()
        try await transactionRepository.update(updated)
    }
}
