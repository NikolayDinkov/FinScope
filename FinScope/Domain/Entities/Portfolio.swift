import Foundation

struct Portfolio: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    let createdAt: Date
    var userId: UUID
    var investments: [Investment]

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        userId: UUID,
        investments: [Investment] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.userId = userId
        self.investments = investments
    }
}
