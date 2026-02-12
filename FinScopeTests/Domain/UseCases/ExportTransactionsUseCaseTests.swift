import Testing
import Foundation
@testable import FinScope

struct ExportTransactionsUseCaseTests {
    @Test func testExportGeneratesCSVData() async throws {
        let txRepo = MockTransactionRepository()
        let categoryRepo = MockCategoryRepository()
        let accountId = UUID()

        let category = FinScope.Category(
            name: "Food",
            icon: "fork.knife",
            colorHex: "#FF9500",
            transactionType: .expense
        )
        categoryRepo.categories = [category]

        txRepo.transactions = [
            FinScope.Transaction(
                accountId: accountId,
                type: .expense,
                amount: 50,
                categoryId: category.id,
                note: "Lunch"
            )
        ]

        let useCase = ExportTransactionsUseCase(
            transactionRepository: txRepo,
            categoryRepository: categoryRepo
        )

        let data = try await useCase.execute(accountId: accountId)
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content.contains("Food"))
        #expect(content.contains("50"))
        #expect(content.contains("expense"))
    }
}
