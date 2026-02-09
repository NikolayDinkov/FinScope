import CoreData

@objc(UserMO)
public class UserMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var email: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var accounts: NSSet?
    @NSManaged public var budgets: NSSet?
    @NSManaged public var portfolios: NSSet?
    @NSManaged public var forecasts: NSSet?
}

extension UserMO {
    static var entityName: String { "UserMO" }

    static func fetchRequest() -> NSFetchRequest<UserMO> {
        NSFetchRequest<UserMO>(entityName: entityName)
    }
}
