import Foundation

struct ExportTransactionsUseCase: Sendable {
    private let transactionRepository: TransactionRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol

    init(
        transactionRepository: TransactionRepositoryProtocol,
        categoryRepository: CategoryRepositoryProtocol
    ) {
        self.transactionRepository = transactionRepository
        self.categoryRepository = categoryRepository
    }

    func execute(accountId: UUID) async throws -> Data {
        let transactions = try await transactionRepository.fetchAll(for: accountId)
        let categories = try await categoryRepository.fetchAll()

        let formatter = ISO8601DateFormatter()

        let records: [[String: String]] = transactions.map { transaction in
            let categoryName = categories.first { $0.id == transaction.categoryId }?.name ?? ""
            return [
                "date": formatter.string(from: transaction.date),
                "type": transaction.type.rawValue,
                "amount": "\(transaction.amount)",
                "category": categoryName,
                "note": transaction.note
            ]
        }

        return CSVParser.generate(from: records)
    }
}
