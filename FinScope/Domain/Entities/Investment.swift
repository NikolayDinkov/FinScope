import Foundation

struct Investment: Identifiable, Hashable, Sendable {
    let id: UUID
    var assetType: AssetType
    var name: String
    var initialCapital: Decimal
    var monthlyContribution: Decimal
    var expectedReturn: Decimal
    var riskProfile: RiskProfile
    var taxRate: Decimal
    var inflationRate: Decimal
    var startDate: Date
    var durationMonths: Int
    var portfolioId: UUID

    init(
        id: UUID = UUID(),
        assetType: AssetType,
        name: String,
        initialCapital: Decimal,
        monthlyContribution: Decimal = 0,
        expectedReturn: Decimal,
        riskProfile: RiskProfile,
        taxRate: Decimal = Decimal(string: "0.10")!,
        inflationRate: Decimal = Decimal(string: "0.03")!,
        startDate: Date = Date(),
        durationMonths: Int,
        portfolioId: UUID
    ) {
        self.id = id
        self.assetType = assetType
        self.name = name
        self.initialCapital = initialCapital
        self.monthlyContribution = monthlyContribution
        self.expectedReturn = expectedReturn
        self.riskProfile = riskProfile
        self.taxRate = taxRate
        self.inflationRate = inflationRate
        self.startDate = startDate
        self.durationMonths = durationMonths
        self.portfolioId = portfolioId
    }
}

enum AssetType: String, CaseIterable, Sendable, Codable {
    case stock
    case etf
    case bond
}

enum RiskProfile: String, CaseIterable, Sendable, Codable {
    case low
    case medium
    case high
}
