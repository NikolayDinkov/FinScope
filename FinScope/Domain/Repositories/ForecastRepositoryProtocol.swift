import Foundation

protocol ForecastRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Forecast]
    func fetchByUser(_ userId: UUID) async throws -> [Forecast]
    func fetch(byId id: UUID) async throws -> Forecast?
    func save(_ forecast: Forecast) async throws
    func delete(_ forecast: Forecast) async throws
}
