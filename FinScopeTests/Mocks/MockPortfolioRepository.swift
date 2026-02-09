import Foundation
@testable import FinScope

final class MockPortfolioRepository: PortfolioRepositoryProtocol, @unchecked Sendable {
    var portfolios: [Portfolio] = []
    var shouldThrow = false
    var saveCalled = false

    func fetchAll() async throws -> [Portfolio] {
        if shouldThrow { throw MockError.testError }
        return portfolios
    }

    func fetchByUser(_ userId: UUID) async throws -> [Portfolio] {
        if shouldThrow { throw MockError.testError }
        return portfolios.filter { $0.userId == userId }
    }

    func fetch(byId id: UUID) async throws -> Portfolio? {
        if shouldThrow { throw MockError.testError }
        return portfolios.first { $0.id == id }
    }

    func save(_ portfolio: Portfolio) async throws {
        if shouldThrow { throw MockError.testError }
        saveCalled = true
        if let index = portfolios.firstIndex(where: { $0.id == portfolio.id }) {
            portfolios[index] = portfolio
        } else {
            portfolios.append(portfolio)
        }
    }

    func delete(_ portfolio: Portfolio) async throws {
        if shouldThrow { throw MockError.testError }
        portfolios.removeAll { $0.id == portfolio.id }
    }
}
