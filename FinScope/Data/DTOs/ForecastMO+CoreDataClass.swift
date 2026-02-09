import CoreData

@objc(ForecastMO)
public class ForecastMO: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var createdAt: Date
    @NSManaged public var projectionMonths: Int32
    @NSManaged public var resultJSON: String
    @NSManaged public var user: UserMO?
}

extension ForecastMO {
    static var entityName: String { "ForecastMO" }

    static func fetchRequest() -> NSFetchRequest<ForecastMO> {
        NSFetchRequest<ForecastMO>(entityName: entityName)
    }
}
