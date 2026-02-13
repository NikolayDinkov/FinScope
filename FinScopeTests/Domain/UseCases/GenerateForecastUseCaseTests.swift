import Testing
import Foundation
@testable import FinScope

struct GenerateForecastUseCaseTests {
    @Test func testGenerateForecastReturnsForecastsFromService() async throws {
        let accountRepo = MockAccountRepository()
        accountRepo.accounts = [Account(name: "Bank", type: .bank, balance: 5000)]

        let txRepo = MockTransactionRepository()

        let mockService = MockForecastService()
        let expectedForecast = MonthlyForecast(
            month: Date().adding(months: 1).startOfMonth,
            projectedIncome: 3000,
            projectedExpenses: 2000,
            netCashFlow: 1000,
            projectedBalance: 6000
        )
        mockService.result = [expectedForecast]

        let useCase = GenerateForecastUseCase(
            accountRepository: accountRepo,
            transactionRepository: txRepo,
            forecastService: mockService
        )

        let result = try await useCase.execute(horizon: .threeMonths)
        #expect(result.count == 1)
        #expect(result.first?.projectedBalance == 6000)
    }

    @Test func testGenerateForecastPropagatesRepositoryError() async throws {
        let accountRepo = MockAccountRepository()
        accountRepo.shouldThrow = true

        let txRepo = MockTransactionRepository()
        let mockService = MockForecastService()

        let useCase = GenerateForecastUseCase(
            accountRepository: accountRepo,
            transactionRepository: txRepo,
            forecastService: mockService
        )

        await #expect(throws: MockError.self) {
            try await useCase.execute(horizon: .sixMonths)
        }
    }

    @Test func testGenerateForecastReturnsEmptyForNoAccounts() async throws {
        let accountRepo = MockAccountRepository()
        let txRepo = MockTransactionRepository()
        let mockService = MockForecastService()
        mockService.result = []

        let useCase = GenerateForecastUseCase(
            accountRepository: accountRepo,
            transactionRepository: txRepo,
            forecastService: mockService
        )

        let result = try await useCase.execute(horizon: .threeMonths)
        #expect(result.isEmpty)
    }
}
