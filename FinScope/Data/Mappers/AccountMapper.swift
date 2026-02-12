import CoreData

struct AccountMapper {
    static func toDomain(_ mo: AccountMO) -> Account {
        Account(
            id: mo.id ?? UUID(),
            name: mo.name ?? "",
            type: AccountType(rawValue: mo.typeRaw ?? "bank") ?? .bank,
            currencyCode: mo.currencyCode ?? "USD",
            balance: mo.balance as? Decimal ?? 0,
            createdAt: mo.createdAt ?? Date(),
            updatedAt: mo.updatedAt ?? Date()
        )
    }

    static func toManagedObject(_ entity: Account, context: NSManagedObjectContext) -> AccountMO {
        let mo = AccountMO(context: context)
        mo.id = entity.id
        mo.name = entity.name
        mo.typeRaw = entity.type.rawValue
        mo.currencyCode = entity.currencyCode
        mo.balance = entity.balance as NSDecimalNumber
        mo.createdAt = entity.createdAt
        mo.updatedAt = entity.updatedAt
        return mo
    }

    static func update(_ mo: AccountMO, from entity: Account) {
        mo.name = entity.name
        mo.typeRaw = entity.type.rawValue
        mo.currencyCode = entity.currencyCode
        mo.balance = entity.balance as NSDecimalNumber
        mo.updatedAt = entity.updatedAt
    }
}
