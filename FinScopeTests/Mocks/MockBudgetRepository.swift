import Foundation
@testable import FinScope

final class MockBudgetRepository: BudgetRepositoryProtocol, @unchecked Sendable {
    var budgets: [Budget] = []
    var shouldThrow = false

    func fetchAll() async throws -> [Budget] {
        if shouldThrow { throw MockError.generic }
        return budgets
    }

    func fetchById(_ id: UUID) async throws -> Budget? {
        if shouldThrow { throw MockError.generic }
        return budgets.first { $0.id == id }
    }

    func create(_ budget: Budget) async throws {
        if shouldThrow { throw MockError.generic }
        budgets.append(budget)
    }

    func update(_ budget: Budget) async throws {
        if shouldThrow { throw MockError.generic }
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
        }
    }

    func delete(_ id: UUID) async throws {
        if shouldThrow { throw MockError.generic }
        budgets.removeAll { $0.id == id }
    }
}
