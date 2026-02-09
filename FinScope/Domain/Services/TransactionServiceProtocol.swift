import Foundation

protocol TransactionServiceProtocol: Sendable {
    func addTransaction(_ transaction: Transaction, toAccount account: Account) async throws
    func importCSV(url: URL, account: Account) async throws -> [Transaction]
    func exportCSV(transactions: [Transaction]) throws -> Data
}
