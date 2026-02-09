import Foundation

@Observable
final class ForecastViewModel {
    private let generateForecast: GenerateForecastUseCase
    private let forecastRepository: any ForecastRepositoryProtocol

    var forecasts: [Forecast] = []
    var currentForecast: Forecast?
    var projectionMonths: Int = 24
    var errorMessage: String?
    var isGenerating = false

    init(generateForecast: GenerateForecastUseCase, forecastRepository: any ForecastRepositoryProtocol) {
        self.generateForecast = generateForecast
        self.forecastRepository = forecastRepository
    }

    func load() async {
        do {
            forecasts = try await forecastRepository.fetchAll()
            currentForecast = forecasts.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generate(userId: UUID) async {
        isGenerating = true
        defer { isGenerating = false }

        do {
            let forecast = try await generateForecast.execute(userId: userId, months: projectionMonths)
            currentForecast = forecast
            forecasts.insert(forecast, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
