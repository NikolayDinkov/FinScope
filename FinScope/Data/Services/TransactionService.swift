import Foundation

struct TransactionService: TransactionServiceProtocol {
    private let transactionRepository: any TransactionRepositoryProtocol
    private let currencyConverter: CurrencyConverter

    init(transactionRepository: any TransactionRepositoryProtocol,
         currencyConverter: CurrencyConverter) {
        self.transactionRepository = transactionRepository
        self.currencyConverter = currencyConverter
    }

    func addTransaction(_ transaction: Transaction, toAccount account: Account) async throws {
        var tx = transaction
        tx.accountId = account.id

        // Convert currency if needed
        if let originalCurrency = tx.originalCurrency, originalCurrency != account.currency {
            let convertedAmount = try await currencyConverter.convert(
                amount: tx.originalAmount ?? tx.amount,
                from: originalCurrency,
                to: account.currency
            )
            tx.originalAmount = tx.amount
            tx.originalCurrency = originalCurrency
            tx.amount = convertedAmount
        }

        try await transactionRepository.save(tx)
    }

    func importCSV(url: URL, account: Account) async throws -> [Transaction] {
        let data = try Data(contentsOf: url)
        guard let content = String(data: data, encoding: .utf8) else {
            throw TransactionError.importFailed("Unable to read file")
        }

        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else {
            throw TransactionError.importFailed("CSV file is empty or has no data rows")
        }

        // Expected format: date,amount,type,note,category
        var transactions: [Transaction] = []

        for line in lines.dropFirst() { // Skip header
            let fields = line.components(separatedBy: ",").map { $0.trimmed }
            guard fields.count >= 3 else { continue }

            guard let date = DateFormatter.csvDate.date(from: fields[0]) else { continue }
            guard let amount = Decimal(string: fields[1]), amount > 0 else { continue }
            guard let type = TransactionType(rawValue: fields[2].lowercased()) else { continue }

            let note = fields.count > 3 ? fields[3].nilIfEmpty : nil

            let transaction = Transaction(
                amount: amount,
                date: date,
                note: note,
                type: type,
                accountId: account.id
            )
            transactions.append(transaction)
        }

        try await transactionRepository.saveAll(transactions)
        return transactions
    }

    func exportCSV(transactions: [Transaction]) throws -> Data {
        var csv = "date,amount,type,note\n"
        for tx in transactions {
            let dateStr = DateFormatter.csvDate.string(from: tx.date)
            let note = tx.note?.replacingOccurrences(of: ",", with: ";") ?? ""
            csv += "\(dateStr),\(tx.amount),\(tx.type.rawValue),\(note)\n"
        }
        guard let data = csv.data(using: .utf8) else {
            throw TransactionError.exportFailed
        }
        return data
    }
}
