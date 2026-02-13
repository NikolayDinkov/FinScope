import Foundation

struct AddTransactionUseCase: Sendable {
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
        var finalTransaction = transaction

        if let originalAmount = transaction.originalAmount,
           let originalCurrency = transaction.originalCurrencyCode,
           let account = try await accountRepository.fetchById(transaction.accountId),
           originalCurrency != account.currencyCode {
            finalTransaction.amount = CurrencyConverter.convert(
                amount: originalAmount,
                from: originalCurrency,
                to: account.currencyCode
            )
        }

        try await transactionRepository.create(finalTransaction)

        if var account = try await accountRepository.fetchById(transaction.accountId) {
            switch finalTransaction.type {
            case .income:
                account.balance += finalTransaction.amount
            case .expense:
                account.balance -= finalTransaction.amount
            case .transfer:
                account.balance -= finalTransaction.amount
            }
            account.updatedAt = Date()
            try await accountRepository.update(account)
        }

        if finalTransaction.type == .transfer,
           let destinationId = finalTransaction.destinationAccountId,
           var destinationAccount = try await accountRepository.fetchById(destinationId) {
            let creditAmount: Decimal
            let sourceAccount = try await accountRepository.fetchById(transaction.accountId)
            if let sourceAccount, sourceAccount.currencyCode != destinationAccount.currencyCode {
                creditAmount = CurrencyConverter.convert(
                    amount: finalTransaction.amount,
                    from: sourceAccount.currencyCode,
                    to: destinationAccount.currencyCode
                )
            } else {
                creditAmount = finalTransaction.amount
            }
            destinationAccount.balance += creditAmount
            destinationAccount.updatedAt = Date()
            try await accountRepository.update(destinationAccount)
        }
    }
}
