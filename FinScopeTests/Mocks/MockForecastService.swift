import Foundation
@testable import FinScope

final class MockForecastService: ForecastServiceProtocol, @unchecked Sendable {
    var result: [MonthlyForecast] = []
    var shouldThrow = false

    func generateForecast(
        accounts: [Account],
        transactions: [FinScope.Transaction],
        horizon: ForecastHorizon,
        referenceDate: Date
    ) async throws -> [MonthlyForecast] {
        if shouldThrow { throw MockError.generic }
        return result
    }
}
