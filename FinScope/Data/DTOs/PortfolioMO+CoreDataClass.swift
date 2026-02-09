import CoreData

@objc(PortfolioMO)
public class PortfolioMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var createdAt: Date
    @NSManaged public var user: UserMO?
    @NSManaged public var investments: NSSet?
}

extension PortfolioMO {
    static var entityName: String { "PortfolioMO" }

    static func fetchRequest() -> NSFetchRequest<PortfolioMO> {
        NSFetchRequest<PortfolioMO>(entityName: entityName)
    }
}
