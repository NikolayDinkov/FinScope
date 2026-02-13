import Foundation

protocol PortfolioRepositoryProtocol: Sendable {
    func fetchAllHoldings() async throws -> [PortfolioHolding]
    func fetchHolding(byTicker ticker: String) async throws -> PortfolioHolding?
    func createHolding(_ holding: PortfolioHolding) async throws
    func updateHolding(_ holding: PortfolioHolding) async throws
    func deleteHolding(_ holding: PortfolioHolding) async throws

    func fetchAllTrades() async throws -> [Trade]
    func fetchTrades(forTicker ticker: String) async throws -> [Trade]
    func createTrade(_ trade: Trade) async throws
}
