import Foundation
@testable import FinScope

final class MockBudgetRepository: BudgetRepositoryProtocol, @unchecked Sendable {
    var budgets: [Budget] = []
    var shouldThrow = false
    var saveCalled = false

    func fetchAll() async throws -> [Budget] {
        if shouldThrow { throw MockError.testError }
        return budgets
    }

    func fetchByUser(_ userId: UUID) async throws -> [Budget] {
        if shouldThrow { throw MockError.testError }
        return budgets.filter { $0.userId == userId }
    }

    func fetch(byId id: UUID) async throws -> Budget? {
        if shouldThrow { throw MockError.testError }
        return budgets.first { $0.id == id }
    }

    func save(_ budget: Budget) async throws {
        if shouldThrow { throw MockError.testError }
        saveCalled = true
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
        } else {
            budgets.append(budget)
        }
    }

    func delete(_ budget: Budget) async throws {
        if shouldThrow { throw MockError.testError }
        budgets.removeAll { $0.id == budget.id }
    }
}
