import Foundation

struct Subcategory: Identifiable, Equatable, Sendable {
    let id: UUID
    var categoryId: UUID
    var name: String
    var isDefault: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        categoryId: UUID,
        name: String,
        isDefault: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.isDefault = isDefault
        self.createdAt = createdAt
    }
}
