import Foundation
@testable import FinScope

final class MockSubcategoryRepository: SubcategoryRepositoryProtocol, @unchecked Sendable {
    var subcategories: [FinScope.Subcategory] = []
    var shouldThrow = false

    func fetchAll(for categoryId: UUID) async throws -> [FinScope.Subcategory] {
        if shouldThrow { throw MockError.generic }
        return subcategories.filter { $0.categoryId == categoryId }
    }

    func fetchById(_ id: UUID) async throws -> FinScope.Subcategory? {
        if shouldThrow { throw MockError.generic }
        return subcategories.first { $0.id == id }
    }

    func create(_ subcategory: FinScope.Subcategory) async throws {
        if shouldThrow { throw MockError.generic }
        subcategories.append(subcategory)
    }

    func update(_ subcategory: FinScope.Subcategory) async throws {
        if shouldThrow { throw MockError.generic }
        if let index = subcategories.firstIndex(where: { $0.id == subcategory.id }) {
            subcategories[index] = subcategory
        }
    }

    func delete(_ id: UUID) async throws {
        if shouldThrow { throw MockError.generic }
        subcategories.removeAll { $0.id == id }
    }
}
