import Testing
import Foundation
@testable import FinScope

struct DeleteTransactionUseCaseTests {
    @Test func testDeleteExpenseRestoresBalance() async throws {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let account = Account(name: "Test", type: .bank, balance: 800)
        accountRepo.accounts = [account]

        let transaction = FinScope.Transaction(
            accountId: account.id,
            type: .expense,
            amount: 200,
            categoryId: UUID()
        )
        txRepo.transactions = [transaction]

        let useCase = DeleteTransactionUseCase(
            transactionRepository: txRepo,
            accountRepository: accountRepo
        )
        try await useCase.execute(id: transaction.id)

        #expect(txRepo.transactions.isEmpty)
        #expect(accountRepo.accounts.first?.balance == 1000)
    }

    @Test func testDeleteIncomeDecreasesBalance() async throws {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let account = Account(name: "Test", type: .bank, balance: 1300)
        accountRepo.accounts = [account]

        let transaction = FinScope.Transaction(
            accountId: account.id,
            type: .income,
            amount: 300,
            categoryId: UUID()
        )
        txRepo.transactions = [transaction]

        let useCase = DeleteTransactionUseCase(
            transactionRepository: txRepo,
            accountRepository: accountRepo
        )
        try await useCase.execute(id: transaction.id)

        #expect(accountRepo.accounts.first?.balance == 1000)
    }

    @Test func testDeleteTransferRestoresBothBalances() async throws {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let source = Account(name: "Source", type: .bank, balance: 700)
        let destination = Account(name: "Destination", type: .bank, balance: 800)
        accountRepo.accounts = [source, destination]

        let transaction = FinScope.Transaction(
            accountId: source.id,
            destinationAccountId: destination.id,
            type: .transfer,
            amount: 300,
            categoryId: UUID()
        )
        txRepo.transactions = [transaction]

        let useCase = DeleteTransactionUseCase(
            transactionRepository: txRepo,
            accountRepository: accountRepo
        )
        try await useCase.execute(id: transaction.id)

        let updatedSource = accountRepo.accounts.first { $0.id == source.id }
        let updatedDest = accountRepo.accounts.first { $0.id == destination.id }
        #expect(txRepo.transactions.isEmpty)
        #expect(updatedSource?.balance == 1000)
        #expect(updatedDest?.balance == 500)
    }
}
