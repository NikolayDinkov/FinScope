import CoreData

@objc(BudgetRuleMO)
public class BudgetRuleMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var ruleType: String
    @NSManaged public var limitAmount: NSDecimalNumber?
    @NSManaged public var percentage: NSDecimalNumber?
    @NSManaged public var budget: BudgetMO?
    @NSManaged public var category: CategoryMO?
}

extension BudgetRuleMO {
    static var entityName: String { "BudgetRuleMO" }

    static func fetchRequest() -> NSFetchRequest<BudgetRuleMO> {
        NSFetchRequest<BudgetRuleMO>(entityName: entityName)
    }
}
