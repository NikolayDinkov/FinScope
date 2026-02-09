import CoreData

@objc(BudgetMO)
public class BudgetMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var period: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var totalLimit: NSDecimalNumber?
    @NSManaged public var user: UserMO?
    @NSManaged public var rules: NSSet?
}

extension BudgetMO {
    static var entityName: String { "BudgetMO" }

    static func fetchRequest() -> NSFetchRequest<BudgetMO> {
        NSFetchRequest<BudgetMO>(entityName: entityName)
    }
}
