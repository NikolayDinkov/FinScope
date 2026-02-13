import SwiftUI

@MainActor
final class ForecastCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()

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

    private(set) lazy var forecastViewModel: ForecastViewModel = makeForecastViewModel()

    func start() -> some View {
        ForecastCoordinatorView(coordinator: self)
    }

    private func makeForecastViewModel() -> ForecastViewModel {
        ForecastViewModel(
            generateForecastUseCase: GenerateForecastUseCase(
                accountRepository: accountRepository,
                transactionRepository: transactionRepository,
                forecastService: forecastService
            ),
            fetchAccountsUseCase: FetchAccountsUseCase(repository: accountRepository)
        )
    }
}
