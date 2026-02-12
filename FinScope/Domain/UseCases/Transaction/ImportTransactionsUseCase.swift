import Foundation

struct ImportTransactionsUseCase: Sendable {
    private let transactionRepository: TransactionRepositoryProtocol
    private let accountRepository: AccountRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol

    init(
        transactionRepository: TransactionRepositoryProtocol,
        accountRepository: AccountRepositoryProtocol,
        categoryRepository: CategoryRepositoryProtocol
    ) {
        self.transactionRepository = transactionRepository
        self.accountRepository = accountRepository
        self.categoryRepository = categoryRepository
    }

    func execute(data: Data, accountId: UUID) async throws -> Int {
        let records = try CSVParser.parse(data: data)
        let categories = try await categoryRepository.fetchAll()

        var importedCount = 0

        for record in records {
            guard let amountString = record["amount"],
                  let amount = Decimal(string: amountString),
                  let typeString = record["type"],
                  let type = TransactionType(rawValue: typeString) else {
                continue
            }

            let categoryName = record["category"] ?? ""
            let categoryId = categories.first { $0.name == categoryName }?.id
                ?? categories.first?.id ?? UUID()

            let dateString = record["date"] ?? ""
            let formatter = ISO8601DateFormatter()
            let date = formatter.date(from: dateString) ?? Date()

            let transaction = Transaction(
                accountId: accountId,
                type: type,
                amount: amount,
                categoryId: categoryId,
                note: record["note"] ?? "",
                date: date
            )

            try await transactionRepository.create(transaction)

            if var account = try await accountRepository.fetchById(accountId) {
                switch type {
                case .income:
                    account.balance += amount
                case .expense:
                    account.balance -= amount
                case .transfer:
                    account.balance -= amount
                }
                account.updatedAt = Date()
                try await accountRepository.update(account)
            }

            importedCount += 1
        }

        return importedCount
    }
}
