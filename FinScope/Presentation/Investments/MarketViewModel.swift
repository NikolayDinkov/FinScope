import Foundation
import Combine

@MainActor @Observable
final class MarketViewModel {
    var allAssets: [MockAsset] = []
    var currentPrices: [String: Decimal] = [:]
    var priceChanges: [String: Decimal] = [:]
    var searchText: String = ""
    var selectedFilter: AssetTypeFilter = .all

    var onSelectAsset: ((String) -> Void)?

    private let marketService: MarketSimulatorServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    var filteredAssets: [MockAsset] {
        allAssets.filter { asset in
            let matchesType: Bool
            switch selectedFilter {
            case .all: matchesType = true
            case .stocks: matchesType = asset.type == .stock
            case .bonds: matchesType = asset.type == .bond
            case .etfs: matchesType = asset.type == .etf
            }

            let matchesSearch = searchText.isEmpty ||
                asset.ticker.localizedCaseInsensitiveContains(searchText) ||
                asset.name.localizedCaseInsensitiveContains(searchText)

            return matchesType && matchesSearch
        }
    }

    init(marketService: MarketSimulatorServiceProtocol) {
        self.marketService = marketService

        marketService.priceUpdates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self else { return }
                self.currentPrices = update.prices
                self.priceChanges.merge(update.changes) { _, new in new }
            }
            .store(in: &cancellables)
    }

    func load() {
        allAssets = marketService.allAssets()
        currentPrices = marketService.currentPrices()
        for asset in allAssets {
            if let price = currentPrices[asset.ticker], asset.basePrice != 0 {
                priceChanges[asset.ticker] = ((price - asset.basePrice) / asset.basePrice * 100).rounded(scale: 2)
            }
        }
    }
}
