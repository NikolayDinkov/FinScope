import Foundation

struct FetchCategorySpendingUseCase: Sendable {
    private let transactionRepository: TransactionRepositoryProtocol

    init(transactionRepository: TransactionRepositoryProtocol) {
        self.transactionRepository = transactionRepository
    }

    /// Returns a dictionary mapping categoryId to total expense amount for the given date range.
    func execute(from startDate: Date, to endDate: Date) async throws -> [UUID: Decimal] {
        let transactions = try await transactionRepository.fetchByDateRange(from: startDate, to: endDate)
        var spending: [UUID: Decimal] = [:]
        for transaction in transactions where transaction.type == .expense {
            guard let categoryId = transaction.categoryId else { continue }
            spending[categoryId, default: 0] += transaction.amount
        }
        return spending
    }
}
