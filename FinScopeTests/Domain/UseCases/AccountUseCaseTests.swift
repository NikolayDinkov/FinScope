import Testing
@testable import FinScope

@Suite("Account Use Case Tests")
struct AccountUseCaseTests {

    @Test("CreateAccount succeeds with valid data")
    func createAccountSuccess() async throws {
        let repo = MockAccountRepository()
        let useCase = CreateAccountUseCase(repository: repo)
        let userId = UUID()

        let account = try await useCase.execute(
            name: "My Account",
            type: .bank,
            currency: "BGN",
            userId: userId
        )

        #expect(account.name == "My Account")
        #expect(account.type == .bank)
        #expect(account.currency == "BGN")
        #expect(repo.saveCalled)
    }

    @Test("CreateAccount fails with empty name")
    func createAccountEmptyName() async {
        let repo = MockAccountRepository()
        let useCase = CreateAccountUseCase(repository: repo)

        await #expect(throws: AccountError.self) {
            try await useCase.execute(
                name: "   ",
                type: .bank,
                currency: "BGN",
                userId: UUID()
            )
        }
    }

    @Test("CreateAccount fails with invalid currency")
    func createAccountInvalidCurrency() async {
        let repo = MockAccountRepository()
        let useCase = CreateAccountUseCase(repository: repo)

        await #expect(throws: AccountError.self) {
            try await useCase.execute(
                name: "Test",
                type: .bank,
                currency: "invalid",
                userId: UUID()
            )
        }
    }

    @Test("DeleteAccount succeeds when no transactions")
    func deleteAccountSuccess() async throws {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let useCase = DeleteAccountUseCase(
            accountRepository: accountRepo,
            transactionRepository: txRepo
        )

        let account = Account(name: "Test", type: .bank, userId: UUID())
        accountRepo.accounts = [account]

        try await useCase.execute(account)
        #expect(accountRepo.deleteCalled)
    }

    @Test("DeleteAccount fails when account has transactions")
    func deleteAccountWithTransactions() async {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let useCase = DeleteAccountUseCase(
            accountRepository: accountRepo,
            transactionRepository: txRepo
        )

        let account = Account(name: "Test", type: .bank, userId: UUID())
        txRepo.transactions = [
            Transaction(amount: 100, type: .expense, accountId: account.id)
        ]

        await #expect(throws: AccountError.self) {
            try await useCase.execute(account)
        }
    }

    @Test("FetchAccounts returns all accounts")
    func fetchAccountsAll() async throws {
        let repo = MockAccountRepository()
        let userId = UUID()
        repo.accounts = [
            Account(name: "A", type: .bank, userId: userId),
            Account(name: "B", type: .cash, userId: userId)
        ]
        let useCase = FetchAccountsUseCase(repository: repo)

        let results = try await useCase.executeAll()
        #expect(results.count == 2)
    }
}
