import Foundation

enum AssetType: String, CaseIterable, Sendable, Codable {
    case stock
    case bond
    case etf
}

enum AssetTypeFilter: String, CaseIterable, Sendable {
    case all = "All"
    case stocks = "Stocks"
    case bonds = "Bonds"
    case etfs = "ETFs"
}

struct MockAsset: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let ticker: String
    let type: AssetType
    let sector: String
    let basePrice: Decimal

    init(
        id: String? = nil,
        name: String,
        ticker: String,
        type: AssetType,
        sector: String,
        basePrice: Decimal
    ) {
        self.id = id ?? ticker
        self.name = name
        self.ticker = ticker
        self.type = type
        self.sector = sector
        self.basePrice = basePrice
    }
}
