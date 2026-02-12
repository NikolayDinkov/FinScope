import Testing
import Foundation
@testable import FinScope

struct ImportTransactionsUseCaseTests {
    @Test func testImportFromCSVData() async throws {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let categoryRepo = MockCategoryRepository()

        let account = Account(name: "Test", type: .bank, balance: 0)
        accountRepo.accounts = [account]

        let category = FinScope.Category(
            name: "Food",
            icon: "fork.knife",
            colorHex: "#FF9500",
            transactionType: .expense
        )
        categoryRepo.categories = [category]

        let csvContent = """
        date,type,amount,category,note
        2025-01-15T00:00:00Z,expense,50.00,Food,Groceries
        2025-01-16T00:00:00Z,income,1000.00,Food,Salary
        """
        let data = csvContent.data(using: .utf8)!

        let useCase = ImportTransactionsUseCase(
            transactionRepository: txRepo,
            accountRepository: accountRepo,
            categoryRepository: categoryRepo
        )

        let count = try await useCase.execute(data: data, accountId: account.id)
        #expect(count == 2)
        #expect(txRepo.transactions.count == 2)
    }
}
