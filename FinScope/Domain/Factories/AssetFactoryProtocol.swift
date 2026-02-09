import Foundation

struct AssetConfig {
    var initialCapital: Decimal
    var monthlyContribution: Decimal
    var durationMonths: Int
    var taxRate: Decimal
    var inflationRate: Decimal
    var portfolioId: UUID

    init(
        initialCapital: Decimal,
        monthlyContribution: Decimal = 0,
        durationMonths: Int = 120,
        taxRate: Decimal = Decimal(string: "0.10")!,
        inflationRate: Decimal = Decimal(string: "0.03")!,
        portfolioId: UUID
    ) {
        self.initialCapital = initialCapital
        self.monthlyContribution = monthlyContribution
        self.durationMonths = durationMonths
        self.taxRate = taxRate
        self.inflationRate = inflationRate
        self.portfolioId = portfolioId
    }
}

protocol AssetFactoryProtocol {
    func createAsset(type: AssetType, name: String, config: AssetConfig) -> Investment
}

struct AssetFactory: AssetFactoryProtocol {
    func createAsset(type: AssetType, name: String, config: AssetConfig) -> Investment {
        let (expectedReturn, riskProfile): (Decimal, RiskProfile) = switch type {
        case .stock: (Decimal(string: "0.10")!, .high)
        case .bond:  (Decimal(string: "0.04")!, .low)
        case .etf:   (Decimal(string: "0.07")!, .medium)
        }

        return Investment(
            assetType: type,
            name: name,
            initialCapital: config.initialCapital,
            monthlyContribution: config.monthlyContribution,
            expectedReturn: expectedReturn,
            riskProfile: riskProfile,
            taxRate: config.taxRate,
            inflationRate: config.inflationRate,
            durationMonths: config.durationMonths,
            portfolioId: config.portfolioId
        )
    }
}
