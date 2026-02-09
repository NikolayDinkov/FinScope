import Foundation

struct AddTransactionUseCase: Sendable {
    private let transactionRepository: any TransactionRepositoryProtocol
    private let transactionService: any TransactionServiceProtocol

    init(transactionRepository: any TransactionRepositoryProtocol,
         transactionService: any TransactionServiceProtocol) {
        self.transactionRepository = transactionRepository
        self.transactionService = transactionService
    }

    func execute(_ transaction: Transaction, account: Account) async throws {
        guard transaction.amount > 0 else {
            throw TransactionError.invalidAmount
        }
        try await transactionService.addTransaction(transaction, toAccount: account)
    }
}

enum TransactionError: Error, LocalizedError {
    case invalidAmount
    case importFailed(String)
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .invalidAmount: "Transaction amount must be positive"
        case .importFailed(let reason): "CSV import failed: \(reason)"
        case .exportFailed: "Failed to export transactions"
        }
    }
}
