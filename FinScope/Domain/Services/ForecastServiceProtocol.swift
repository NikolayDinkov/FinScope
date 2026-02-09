import Foundation

protocol ForecastServiceProtocol: Sendable {
    func generateForecast(userId: UUID, months: Int) async throws -> Forecast
    func compareScenarios(_ scenarios: [Forecast]) -> ScenarioComparison
}
