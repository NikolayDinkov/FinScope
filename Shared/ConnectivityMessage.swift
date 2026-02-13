import Foundation

enum ConnectivityMessageKey: String {
    case priceUpdate = "priceUpdate"
    case tradeExecuted = "tradeExecuted"
    case requestPrices = "requestPrices"
}

struct CodablePriceUpdate: Codable, Sendable {
    let prices: [String: String]
    let changes: [String: String]
    let timestamp: Date

    init(from update: MarketPriceUpdate) {
        var prices: [String: String] = [:]
        for (key, value) in update.prices {
            prices[key] = "\(value)"
        }
        var changes: [String: String] = [:]
        for (key, value) in update.changes {
            changes[key] = "\(value)"
        }
        self.prices = prices
        self.changes = changes
        self.timestamp = update.timestamp
    }

    func toMarketPriceUpdate() -> MarketPriceUpdate {
        var decimalPrices: [String: Decimal] = [:]
        for (key, value) in prices {
            decimalPrices[key] = Decimal(string: value) ?? 0
        }
        var decimalChanges: [String: Decimal] = [:]
        for (key, value) in changes {
            decimalChanges[key] = Decimal(string: value) ?? 0
        }
        return MarketPriceUpdate(
            prices: decimalPrices,
            changes: decimalChanges,
            timestamp: timestamp
        )
    }
}
