import CoreData

struct CategoryMapper {
    static func toDomain(_ mo: CategoryMO) -> Category {
        Category(
            id: mo.id ?? UUID(),
            name: mo.name ?? "",
            icon: mo.icon ?? "circle.fill",
            colorHex: mo.colorHex ?? "#007AFF",
            isDefault: mo.isDefault,
            transactionType: TransactionType(rawValue: mo.transactionTypeRaw ?? "expense") ?? .expense,
            createdAt: mo.createdAt ?? Date()
        )
    }

    static func toManagedObject(_ entity: Category, context: NSManagedObjectContext) -> CategoryMO {
        let mo = CategoryMO(context: context)
        mo.id = entity.id
        mo.name = entity.name
        mo.icon = entity.icon
        mo.colorHex = entity.colorHex
        mo.isDefault = entity.isDefault
        mo.transactionTypeRaw = entity.transactionType.rawValue
        mo.createdAt = entity.createdAt
        return mo
    }

    static func update(_ mo: CategoryMO, from entity: Category) {
        mo.name = entity.name
        mo.icon = entity.icon
        mo.colorHex = entity.colorHex
        mo.transactionTypeRaw = entity.transactionType.rawValue
    }
}
