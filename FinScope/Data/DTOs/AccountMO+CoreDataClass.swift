import CoreData

@objc(AccountMO)
public class AccountMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var type: String
    @NSManaged public var currency: String
    @NSManaged public var createdAt: Date
    @NSManaged public var user: UserMO?
    @NSManaged public var transactions: NSSet?
}

extension AccountMO {
    static var entityName: String { "AccountMO" }

    static func fetchRequest() -> NSFetchRequest<AccountMO> {
        NSFetchRequest<AccountMO>(entityName: entityName)
    }
}
