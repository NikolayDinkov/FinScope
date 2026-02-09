import Foundation

struct ImportTransactionsUseCase: Sendable {
    private let transactionService: any TransactionServiceProtocol

    init(transactionService: any TransactionServiceProtocol) {
        self.transactionService = transactionService
    }

    func execute(csvURL: URL, account: Account) async throws -> [Transaction] {
        try await transactionService.importCSV(url: csvURL, account: account)
    }

    func exportCSV(transactions: [Transaction]) throws -> Data {
        try transactionService.exportCSV(transactions: transactions)
    }
}
