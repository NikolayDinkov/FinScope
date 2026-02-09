import CoreData

@objc(InvestmentMO)
public class InvestmentMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var assetType: String
    @NSManaged public var name: String
    @NSManaged public var initialCapital: NSDecimalNumber
    @NSManaged public var monthlyContribution: NSDecimalNumber
    @NSManaged public var expectedReturn: NSDecimalNumber
    @NSManaged public var riskProfile: String
    @NSManaged public var taxRate: NSDecimalNumber
    @NSManaged public var inflationRate: NSDecimalNumber
    @NSManaged public var startDate: Date
    @NSManaged public var durationMonths: Int32
    @NSManaged public var portfolio: PortfolioMO?
}

extension InvestmentMO {
    static var entityName: String { "InvestmentMO" }

    static func fetchRequest() -> NSFetchRequest<InvestmentMO> {
        NSFetchRequest<InvestmentMO>(entityName: entityName)
    }
}
