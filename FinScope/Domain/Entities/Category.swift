import Foundation

struct Category: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var icon: String?
    var type: TransactionType
    var parentId: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        icon: String? = nil,
        type: TransactionType,
        parentId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.type = type
        self.parentId = parentId
    }
}
