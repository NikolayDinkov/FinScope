import SwiftUI

@MainActor
final class InvestmentsCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()
    @Published var sheet: InvestmentsSheet?

    enum InvestmentsSheet: Identifiable {
        case tradeForm(ticker: String, action: TradeAction)

        var id: String {
            switch self {
            case .tradeForm(let ticker, let action):
                "tradeForm-\(ticker)-\(action.rawValue)"
            }
        }
    }

    private let portfolioRepository: PortfolioRepositoryProtocol
    private let marketService: MarketSimulatorServiceProtocol

    init(
        portfolioRepository: PortfolioRepositoryProtocol,
        marketService: MarketSimulatorServiceProtocol
    ) {
        self.portfolioRepository = portfolioRepository
        self.marketService = marketService
    }

    private(set) lazy var portfolioViewModel: PortfolioViewModel = makePortfolioViewModel()
    private(set) lazy var marketViewModel: MarketViewModel = makeMarketViewModel()
    private var assetDetailViewModels: [String: AssetDetailViewModel] = [:]

    func start() -> some View {
        InvestmentsCoordinatorView(coordinator: self)
    }

    // MARK: - View Model Factories

    private func makePortfolioViewModel() -> PortfolioViewModel {
        let vm = PortfolioViewModel(
            fetchPortfolioUseCase: FetchPortfolioUseCase(repository: portfolioRepository),
            fetchTradeHistoryUseCase: FetchTradeHistoryUseCase(repository: portfolioRepository),
            marketService: marketService
        )
        vm.onOpenMarket = { [weak self] in
            self?.path.append(.market)
        }
        vm.onSelectAsset = { [weak self] ticker in
            self?.path.append(.assetDetail(ticker: ticker))
        }
        return vm
    }

    func makeMarketViewModel() -> MarketViewModel {
        let vm = MarketViewModel(marketService: marketService)
        vm.onSelectAsset = { [weak self] ticker in
            self?.path.append(.assetDetail(ticker: ticker))
        }
        return vm
    }

    func assetDetailViewModel(for ticker: String) -> AssetDetailViewModel {
        if let cached = assetDetailViewModels[ticker] {
            return cached
        }
        let vm = AssetDetailViewModel(
            ticker: ticker,
            marketService: marketService,
            fetchPortfolioUseCase: FetchPortfolioUseCase(repository: portfolioRepository),
            fetchTradeHistoryUseCase: FetchTradeHistoryUseCase(repository: portfolioRepository),
            portfolioRepository: portfolioRepository
        )
        vm.onBuy = { [weak self] in
            self?.sheet = .tradeForm(ticker: ticker, action: .buy)
        }
        vm.onSell = { [weak self] in
            self?.sheet = .tradeForm(ticker: ticker, action: .sell)
        }
        assetDetailViewModels[ticker] = vm
        return vm
    }

    func makeTradeFormViewModel(ticker: String, action: TradeAction) -> TradeFormViewModel {
        let vm = TradeFormViewModel(
            ticker: ticker,
            action: action,
            executeTradeUseCase: ExecuteTradeUseCase(
                repository: portfolioRepository,
                marketService: marketService
            ),
            marketService: marketService,
            portfolioRepository: portfolioRepository
        )
        vm.onSave = { [weak self] in self?.sheet = nil }
        vm.onCancel = { [weak self] in self?.sheet = nil }
        return vm
    }
}
