import CoreData

struct BudgetMapper {
    static func toDomain(_ mo: BudgetMO) -> Budget {
        Budget(
            id: mo.id ?? UUID(),
            categoryId: mo.category?.id ?? UUID(),
            amount: mo.amount as? Decimal ?? 0,
            createdAt: mo.createdAt ?? Date(),
            updatedAt: mo.updatedAt ?? Date()
        )
    }

    static func toManagedObject(_ entity: Budget, context: NSManagedObjectContext) -> BudgetMO {
        let mo = BudgetMO(context: context)
        mo.id = entity.id
        mo.amount = entity.amount as NSDecimalNumber
        mo.createdAt = entity.createdAt
        mo.updatedAt = entity.updatedAt
        return mo
    }

    static func update(_ mo: BudgetMO, from entity: Budget) {
        mo.amount = entity.amount as NSDecimalNumber
        mo.updatedAt = entity.updatedAt
    }
}
