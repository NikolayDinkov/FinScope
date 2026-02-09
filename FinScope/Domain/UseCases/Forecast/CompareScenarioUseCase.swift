import Foundation

struct CompareScenarioUseCase: Sendable {
    private let forecastService: any ForecastServiceProtocol

    init(forecastService: any ForecastServiceProtocol) {
        self.forecastService = forecastService
    }

    func execute(scenarios: [Forecast]) -> ScenarioComparison {
        forecastService.compareScenarios(scenarios)
    }
}
