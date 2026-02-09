import CoreData

@objc(CategoryMO)
public class CategoryMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var icon: String?
    @NSManaged public var type: String
    @NSManaged public var transactions: NSSet?
    @NSManaged public var parent: CategoryMO?
    @NSManaged public var children: NSSet?
    @NSManaged public var budgetRules: NSSet?
}

extension CategoryMO {
    static var entityName: String { "CategoryMO" }

    static func fetchRequest() -> NSFetchRequest<CategoryMO> {
        NSFetchRequest<CategoryMO>(entityName: entityName)
    }
}
