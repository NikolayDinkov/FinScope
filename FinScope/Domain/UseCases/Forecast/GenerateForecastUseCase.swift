import Foundation

struct GenerateForecastUseCase: Sendable {
    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let forecastService: ForecastServiceProtocol

    init(
        accountRepository: AccountRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol,
        forecastService: ForecastServiceProtocol
    ) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.forecastService = forecastService
    }

    func execute(
        horizon: ForecastHorizon,
        referenceDate: Date = Date()
    ) async throws -> [MonthlyForecast] {
        let accounts = try await accountRepository.fetchAll()
        let transactions = try await transactionRepository.fetchAll()
        return try await forecastService.generateForecast(
            accounts: accounts,
            transactions: transactions,
            horizon: horizon,
            referenceDate: referenceDate
        )
    }
}
