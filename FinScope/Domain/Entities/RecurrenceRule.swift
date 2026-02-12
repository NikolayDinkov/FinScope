import Foundation

enum RecurrenceFrequency: String, CaseIterable, Sendable, Codable {
    case daily
    case weekly
    case biweekly
    case monthly
    case quarterly
    case yearly
}

struct RecurrenceRule: Equatable, Sendable, Codable {
    var frequency: RecurrenceFrequency
    var startDate: Date
    var endDate: Date?
    var nextOccurrence: Date

    init(
        frequency: RecurrenceFrequency,
        startDate: Date = Date(),
        endDate: Date? = nil,
        nextOccurrence: Date? = nil
    ) {
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.nextOccurrence = nextOccurrence ?? startDate
    }
}
