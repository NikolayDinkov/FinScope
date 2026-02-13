import Foundation
import Combine

@MainActor @Observable
final class ForecastViewModel {
    var forecasts: [MonthlyForecast] = []
    var selectedHorizon: ForecastHorizon = .sixMonths
    var currentBalance: Decimal = 0
    var errorMessage: String?
    var isLoading = false

    private let generateForecastUseCase: GenerateForecastUseCase
    private let fetchAccountsUseCase: FetchAccountsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        generateForecastUseCase: GenerateForecastUseCase,
        fetchAccountsUseCase: FetchAccountsUseCase
    ) {
        self.generateForecastUseCase = generateForecastUseCase
        self.fetchAccountsUseCase = fetchAccountsUseCase

        NotificationCenter.default.publisher(for: .dataDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.load() }
            }
            .store(in: &cancellables)
    }

    var projectedEndBalance: Decimal {
        forecasts.last?.projectedBalance ?? currentBalance
    }

    var balanceChange: Decimal {
        projectedEndBalance - currentBalance
    }

    func load() async {
        isLoading = true
        do {
            let accounts = try await fetchAccountsUseCase.execute()
            currentBalance = accounts.reduce(Decimal.zero) { $0 + $1.balance }
            forecasts = try await generateForecastUseCase.execute(horizon: selectedHorizon)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func changeHorizon(to horizon: ForecastHorizon) {
        selectedHorizon = horizon
        Task { await load() }
    }
}
