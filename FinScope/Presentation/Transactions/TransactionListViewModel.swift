import Foundation

@Observable
final class TransactionListViewModel {
    private let fetchTransactions: FetchTransactionsUseCase

    var transactions: [Transaction] = []
    var errorMessage: String?

    var incomeTransactions: [Transaction] {
        transactions.filter { $0.type == .income }
    }

    var expenseTransactions: [Transaction] {
        transactions.filter { $0.type == .expense }
    }

    init(fetchTransactions: FetchTransactionsUseCase) {
        self.fetchTransactions = fetchTransactions
    }

    func load() async {
        do {
            transactions = try await fetchTransactions.executeAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
