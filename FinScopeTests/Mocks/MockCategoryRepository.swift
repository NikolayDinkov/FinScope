import Foundation
@testable import FinScope

final class MockCategoryRepository: CategoryRepositoryProtocol, @unchecked Sendable {
    var categories: [FinScope.Category] = []
    var shouldThrow = false
    var seedWasCalled = false

    func fetchAll() async throws -> [FinScope.Category] {
        if shouldThrow { throw MockError.generic }
        return categories
    }

    func fetchByType(_ type: TransactionType) async throws -> [FinScope.Category] {
        if shouldThrow { throw MockError.generic }
        return categories.filter { $0.transactionType == type }
    }

    func fetchById(_ id: UUID) async throws -> FinScope.Category? {
        if shouldThrow { throw MockError.generic }
        return categories.first { $0.id == id }
    }

    func create(_ category: FinScope.Category) async throws {
        if shouldThrow { throw MockError.generic }
        categories.append(category)
    }

    func update(_ category: FinScope.Category) async throws {
        if shouldThrow { throw MockError.generic }
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
        }
    }

    func delete(_ id: UUID) async throws {
        if shouldThrow { throw MockError.generic }
        categories.removeAll { $0.id == id }
    }

    func seedDefaultsIfNeeded(defaults: [FinScope.Category]) async throws {
        if shouldThrow { throw MockError.generic }
        seedWasCalled = true
        if categories.isEmpty {
            categories = defaults
        }
    }
}
