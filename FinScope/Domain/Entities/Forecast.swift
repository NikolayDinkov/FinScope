import Foundation

struct Forecast: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    let createdAt: Date
    var projectionMonths: Int
    var monthlyProjections: [ForecastMonth]
    var userId: UUID

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        projectionMonths: Int,
        monthlyProjections: [ForecastMonth] = [],
        userId: UUID
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.projectionMonths = projectionMonths
        self.monthlyProjections = monthlyProjections
        self.userId = userId
    }
}

struct ForecastMonth: Equatable, Sendable, Codable {
    let month: Int
    var income: Decimal
    var expenses: Decimal
    var savings: Decimal
    var investmentValue: Decimal
    var netWorth: Decimal
}

struct ScenarioComparison: Equatable, Sendable {
    let scenarios: [Forecast]
    let differencesByMonth: [[Decimal]]
}
