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
        let oldTransaction = try await transactionRepository.fetchById(transaction.id)

        // Reverse old source account balance
        if let oldTransaction,
           var account = try await accountRepository.fetchById(oldTransaction.accountId) {
            switch oldTransaction.type {
            case .income:
                account.balance -= oldTransaction.amount
            case .expense:
                account.balance += oldTransaction.amount
            case .transfer:
                account.balance += oldTransaction.amount
            }
            account.updatedAt = Date()
            try await accountRepository.update(account)
        }

        // Reverse old destination account balance
        if let oldTransaction, oldTransaction.type == .transfer,
           let oldDestId = oldTransaction.destinationAccountId,
           var oldDest = try await accountRepository.fetchById(oldDestId) {
            let debitAmount: Decimal
            let sourceAccount = try await accountRepository.fetchById(oldTransaction.accountId)
            if let sourceAccount, sourceAccount.currencyCode != oldDest.currencyCode {
                debitAmount = CurrencyConverter.convert(
                    amount: oldTransaction.amount,
                    from: sourceAccount.currencyCode,
                    to: oldDest.currencyCode
                )
            } else {
                debitAmount = oldTransaction.amount
            }
            oldDest.balance -= debitAmount
            oldDest.updatedAt = Date()
            try await accountRepository.update(oldDest)
        }

        // Apply new source account balance
        if var account = try await accountRepository.fetchById(transaction.accountId) {
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

        // Apply new destination account balance
        if transaction.type == .transfer,
           let destId = transaction.destinationAccountId,
           var dest = try await accountRepository.fetchById(destId) {
            let creditAmount: Decimal
            let sourceAccount = try await accountRepository.fetchById(transaction.accountId)
            if let sourceAccount, sourceAccount.currencyCode != dest.currencyCode {
                creditAmount = CurrencyConverter.convert(
                    amount: transaction.amount,
                    from: sourceAccount.currencyCode,
                    to: dest.currencyCode
                )
            } else {
                creditAmount = transaction.amount
            }
            dest.balance += creditAmount
            dest.updatedAt = Date()
            try await accountRepository.update(dest)
        }

        var updated = transaction
        updated.updatedAt = Date()
        try await transactionRepository.update(updated)
    }
}
