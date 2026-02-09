import CoreData

@objc(TransactionMO)
public class TransactionMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var originalAmount: NSDecimalNumber?
    @NSManaged public var originalCurrency: String?
    @NSManaged public var date: Date
    @NSManaged public var note: String?
    @NSManaged public var isRecurring: Bool
    @NSManaged public var recurringInterval: String?
    @NSManaged public var type: String
    @NSManaged public var createdAt: Date
    @NSManaged public var account: AccountMO?
    @NSManaged public var category: CategoryMO?
}

extension TransactionMO {
    static var entityName: String { "TransactionMO" }

    static func fetchRequest() -> NSFetchRequest<TransactionMO> {
        NSFetchRequest<TransactionMO>(entityName: entityName)
    }
}
