import Foundation
@testable import FinScope

final class MockPortfolioRepository: PortfolioRepositoryProtocol, @unchecked Sendable {
    var holdings: [PortfolioHolding] = []
    var trades: [Trade] = []
    var shouldThrow = false

    func fetchAllHoldings() async throws -> [PortfolioHolding] {
        if shouldThrow { throw MockError.generic }
        return holdings
    }

    func fetchHolding(byTicker ticker: String) async throws -> PortfolioHolding? {
        if shouldThrow { throw MockError.generic }
        return holdings.first { $0.assetTicker == ticker }
    }

    func createHolding(_ holding: PortfolioHolding) async throws {
        if shouldThrow { throw MockError.generic }
        holdings.append(holding)
    }

    func updateHolding(_ holding: PortfolioHolding) async throws {
        if shouldThrow { throw MockError.generic }
        if let index = holdings.firstIndex(where: { $0.id == holding.id }) {
            holdings[index] = holding
        }
    }

    func deleteHolding(_ holding: PortfolioHolding) async throws {
        if shouldThrow { throw MockError.generic }
        holdings.removeAll { $0.id == holding.id }
    }

    func fetchAllTrades() async throws -> [Trade] {
        if shouldThrow { throw MockError.generic }
        return trades
    }

    func fetchTrades(forTicker ticker: String) async throws -> [Trade] {
        if shouldThrow { throw MockError.generic }
        return trades.filter { $0.assetTicker == ticker }
    }

    func createTrade(_ trade: Trade) async throws {
        if shouldThrow { throw MockError.generic }
        trades.append(trade)
    }
}
