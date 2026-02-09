import Foundation

struct GenerateForecastUseCase: Sendable {
    private let forecastService: any ForecastServiceProtocol
    private let forecastRepository: any ForecastRepositoryProtocol

    init(forecastService: any ForecastServiceProtocol,
         forecastRepository: any ForecastRepositoryProtocol) {
        self.forecastService = forecastService
        self.forecastRepository = forecastRepository
    }

    func execute(userId: UUID, months: Int) async throws -> Forecast {
        let forecast = try await forecastService.generateForecast(userId: userId, months: months)
        try await forecastRepository.save(forecast)
        return forecast
    }
}
