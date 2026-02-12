import CoreData
import Foundation

struct TransactionMapper {
    static func toDomain(_ mo: TransactionMO) -> Transaction {
        var recurrenceRule: RecurrenceRule?
        if let data = mo.recurrenceRuleData {
            recurrenceRule = try? JSONDecoder().decode(RecurrenceRule.self, from: data)
        }

        return Transaction(
            id: mo.id ?? UUID(),
            accountId: mo.account?.id ?? UUID(),
            type: TransactionType(rawValue: mo.typeRaw ?? "expense") ?? .expense,
            amount: mo.amount as? Decimal ?? 0,
            originalAmount: mo.originalAmount as? Decimal,
            originalCurrencyCode: mo.originalCurrencyCode,
            categoryId: mo.category?.id ?? UUID(),
            subcategoryId: mo.subcategory?.id,
            note: mo.note ?? "",
            date: mo.date ?? Date(),
            isRecurring: mo.isRecurring,
            recurrenceRule: recurrenceRule,
            createdAt: mo.createdAt ?? Date(),
            updatedAt: mo.updatedAt ?? Date()
        )
    }

    static func toManagedObject(_ entity: Transaction, context: NSManagedObjectContext) -> TransactionMO {
        let mo = TransactionMO(context: context)
        mo.id = entity.id
        mo.typeRaw = entity.type.rawValue
        mo.amount = entity.amount as NSDecimalNumber
        mo.originalAmount = entity.originalAmount.map { $0 as NSDecimalNumber }
        mo.originalCurrencyCode = entity.originalCurrencyCode
        mo.note = entity.note
        mo.date = entity.date
        mo.isRecurring = entity.isRecurring
        mo.recurrenceRuleData = entity.recurrenceRule.flatMap { try? JSONEncoder().encode($0) }
        mo.createdAt = entity.createdAt
        mo.updatedAt = entity.updatedAt
        return mo
    }

    static func update(_ mo: TransactionMO, from entity: Transaction) {
        mo.typeRaw = entity.type.rawValue
        mo.amount = entity.amount as NSDecimalNumber
        mo.originalAmount = entity.originalAmount.map { $0 as NSDecimalNumber }
        mo.originalCurrencyCode = entity.originalCurrencyCode
        mo.note = entity.note
        mo.date = entity.date
        mo.isRecurring = entity.isRecurring
        mo.recurrenceRuleData = entity.recurrenceRule.flatMap { try? JSONEncoder().encode($0) }
        mo.updatedAt = entity.updatedAt
    }
}
