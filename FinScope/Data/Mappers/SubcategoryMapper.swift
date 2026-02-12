import CoreData

struct SubcategoryMapper {
    static func toDomain(_ mo: SubcategoryMO) -> Subcategory {
        Subcategory(
            id: mo.id ?? UUID(),
            categoryId: mo.category?.id ?? UUID(),
            name: mo.name ?? "",
            isDefault: mo.isDefault,
            createdAt: mo.createdAt ?? Date()
        )
    }

    static func toManagedObject(_ entity: Subcategory, context: NSManagedObjectContext) -> SubcategoryMO {
        let mo = SubcategoryMO(context: context)
        mo.id = entity.id
        mo.name = entity.name
        mo.isDefault = entity.isDefault
        mo.createdAt = entity.createdAt
        return mo
    }

    static func update(_ mo: SubcategoryMO, from entity: Subcategory) {
        mo.name = entity.name
    }
}
