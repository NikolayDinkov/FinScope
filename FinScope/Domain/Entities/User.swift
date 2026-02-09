import Foundation

struct User: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var email: String?
    let createdAt: Date

    init(id: UUID = UUID(), name: String, email: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
    }
}
