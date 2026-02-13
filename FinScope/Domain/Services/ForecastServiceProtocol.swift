import Foundation

enum ForecastHorizon: Int, CaseIterable, Sendable {
    case threeMonths = 3
    case sixMonths = 6
    case twelveMonths = 12
}

protocol ForecastServiceProtocol: Sendable {
    func generateForecast(
        accounts: [Account],
        transactions: [Transaction],
        horizon: ForecastHorizon,
        referenceDate: Date
    ) async throws -> [MonthlyForecast]
}
