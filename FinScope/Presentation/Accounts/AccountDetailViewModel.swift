import Foundation

@MainActor @Observable
final class AccountDetailViewModel {
    private let fetchTransactions: FetchTransactionsUseCase

    let account: Account
    var transactions: [Transaction] = []
    var balance: Decimal = 0
    var errorMessage: String?

    init(account: Account, fetchTransactions: FetchTransactionsUseCase) {
        self.account = account
        self.fetchTransactions = fetchTransactions
    }

    func load() async {
        do {
            transactions = try await fetchTransactions.execute(accountId: account.id)
            balance = transactions.reduce(Decimal.zero) { total, tx in
                tx.type == .income ? total + tx.amount : total - tx.amount
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
