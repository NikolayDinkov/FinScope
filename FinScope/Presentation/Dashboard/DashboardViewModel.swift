import Foundation

@MainActor @Observable
final class DashboardViewModel {
    private let fetchAccounts: FetchAccountsUseCase
    private let fetchTransactions: FetchTransactionsUseCase

    var accounts: [Account] = []
    var recentTransactions: [Transaction] = []
    var totalBalance: Decimal = 0
    var monthlyIncome: Decimal = 0
    var monthlyExpenses: Decimal = 0
    var errorMessage: String?

    init(fetchAccounts: FetchAccountsUseCase, fetchTransactions: FetchTransactionsUseCase) {
        self.fetchAccounts = fetchAccounts
        self.fetchTransactions = fetchTransactions
    }

    func load() async {
        do {
            accounts = try await fetchAccounts.executeAll()
            recentTransactions = try await fetchTransactions.executeAll()

            let currentMonthTransactions = recentTransactions.filter { $0.date.isInCurrentMonth }
            monthlyIncome = currentMonthTransactions
                .filter { $0.type == .income }
                .reduce(Decimal.zero) { $0 + $1.amount }
            monthlyExpenses = currentMonthTransactions
                .filter { $0.type == .expense }
                .reduce(Decimal.zero) { $0 + $1.amount }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
