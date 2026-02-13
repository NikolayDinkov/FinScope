import Testing
import Foundation
@testable import FinScope

struct AddTransactionUseCaseTests {
    @Test func testAddExpenseDecreasesBalance() async throws {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let account = Account(name: "Test", type: .bank, balance: 1000)
        accountRepo.accounts = [account]

        let useCase = AddTransactionUseCase(
            transactionRepository: txRepo,
            accountRepository: accountRepo
        )

        let transaction = FinScope.Transaction(
            accountId: account.id,
            type: .expense,
            amount: 200,
            categoryId: UUID()
        )
        try await useCase.execute(transaction)

        #expect(txRepo.transactions.count == 1)
        #expect(accountRepo.accounts.first?.balance == 800)
    }

    @Test func testAddIncomeIncreasesBalance() async throws {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let account = Account(name: "Test", type: .bank, balance: 500)
        accountRepo.accounts = [account]

        let useCase = AddTransactionUseCase(
            transactionRepository: txRepo,
            accountRepository: accountRepo
        )

        let transaction = FinScope.Transaction(
            accountId: account.id,
            type: .income,
            amount: 300,
            categoryId: UUID()
        )
        try await useCase.execute(transaction)

        #expect(accountRepo.accounts.first?.balance == 800)
    }

    @Test func testAddTransferDebitSourceAndCreditDestination() async throws {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let source = Account(name: "Source", type: .bank, balance: 1000)
        let destination = Account(name: "Destination", type: .bank, balance: 500)
        accountRepo.accounts = [source, destination]

        let useCase = AddTransactionUseCase(
            transactionRepository: txRepo,
            accountRepository: accountRepo
        )

        let transaction = FinScope.Transaction(
            accountId: source.id,
            destinationAccountId: destination.id,
            type: .transfer,
            amount: 300,
            categoryId: UUID()
        )
        try await useCase.execute(transaction)

        let updatedSource = accountRepo.accounts.first { $0.id == source.id }
        let updatedDest = accountRepo.accounts.first { $0.id == destination.id }
        #expect(updatedSource?.balance == 700)
        #expect(updatedDest?.balance == 800)
    }
}
