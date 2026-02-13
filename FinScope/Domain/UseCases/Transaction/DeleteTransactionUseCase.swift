import Foundation

struct DeleteTransactionUseCase: Sendable {
    private let transactionRepository: TransactionRepositoryProtocol
    private let accountRepository: AccountRepositoryProtocol

    init(
        transactionRepository: TransactionRepositoryProtocol,
        accountRepository: AccountRepositoryProtocol
    ) {
        self.transactionRepository = transactionRepository
        self.accountRepository = accountRepository
    }

    func execute(id: UUID) async throws {
        guard let transaction = try await transactionRepository.fetchById(id) else { return }

        if var account = try await accountRepository.fetchById(transaction.accountId) {
            switch transaction.type {
            case .income:
                account.balance -= transaction.amount
            case .expense:
                account.balance += transaction.amount
            case .transfer:
                account.balance += transaction.amount
            }
            account.updatedAt = Date()
            try await accountRepository.update(account)
        }

        if transaction.type == .transfer,
           let destinationId = transaction.destinationAccountId,
           var destinationAccount = try await accountRepository.fetchById(destinationId) {
            let sourceAccount = try await accountRepository.fetchById(transaction.accountId)
            let debitAmount: Decimal
            if let sourceAccount, sourceAccount.currencyCode != destinationAccount.currencyCode {
                debitAmount = CurrencyConverter.convert(
                    amount: transaction.amount,
                    from: sourceAccount.currencyCode,
                    to: destinationAccount.currencyCode
                )
            } else {
                debitAmount = transaction.amount
            }
            destinationAccount.balance -= debitAmount
            destinationAccount.updatedAt = Date()
            try await accountRepository.update(destinationAccount)
        }

        try await transactionRepository.delete(id)
    }
}
