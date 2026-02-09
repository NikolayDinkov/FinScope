import Testing
@testable import FinScope

@Suite("AssetFactory Tests")
struct AssetFactoryTests {

    @Test("Factory creates stock with high risk defaults")
    func createStock() {
        let factory = AssetFactory()
        let config = AssetConfig(initialCapital: 5000, portfolioId: UUID())

        let investment = factory.createAsset(type: .stock, name: "AAPL", config: config)

        #expect(investment.assetType == .stock)
        #expect(investment.name == "AAPL")
        #expect(investment.riskProfile == .high)
        #expect(investment.expectedReturn == Decimal(string: "0.10")!)
        #expect(investment.initialCapital == 5000)
    }

    @Test("Factory creates bond with low risk defaults")
    func createBond() {
        let factory = AssetFactory()
        let config = AssetConfig(initialCapital: 10000, portfolioId: UUID())

        let investment = factory.createAsset(type: .bond, name: "Treasury", config: config)

        #expect(investment.riskProfile == .low)
        #expect(investment.expectedReturn == Decimal(string: "0.04")!)
    }

    @Test("Factory creates ETF with medium risk defaults")
    func createETF() {
        let factory = AssetFactory()
        let config = AssetConfig(
            initialCapital: 20000,
            monthlyContribution: 500,
            durationMonths: 240,
            portfolioId: UUID()
        )

        let investment = factory.createAsset(type: .etf, name: "VOO", config: config)

        #expect(investment.riskProfile == .medium)
        #expect(investment.expectedReturn == Decimal(string: "0.07")!)
        #expect(investment.monthlyContribution == 500)
        #expect(investment.durationMonths == 240)
    }
}
