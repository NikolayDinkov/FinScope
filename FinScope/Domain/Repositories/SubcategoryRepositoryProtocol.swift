import Foundation

protocol SubcategoryRepositoryProtocol: Sendable {
    func fetchAll(for categoryId: UUID) async throws -> [Subcategory]
    func fetchById(_ id: UUID) async throws -> Subcategory?
    func create(_ subcategory: Subcategory) async throws
    func update(_ subcategory: Subcategory) async throws
    func delete(_ id: UUID) async throws
}
