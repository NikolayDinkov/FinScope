import Foundation
import CoreData

struct TradeMapper {
    static func toDomain(_ mo: TradeMO) -> Trade {
        Trade(
            id: mo.id ?? UUID(),
            assetTicker: mo.assetTicker ?? "",
            action: TradeAction(rawValue: mo.actionRaw ?? "buy") ?? .buy,
            quantity: mo.quantity as? Decimal ?? 0,
            pricePerUnit: mo.pricePerUnit as? Decimal ?? 0,
            date: mo.date ?? Date(),
            createdAt: mo.createdAt ?? Date()
        )
    }

    static func toManagedObject(_ entity: Trade, context: NSManagedObjectContext) -> TradeMO {
        let mo = TradeMO(context: context)
        mo.id = entity.id
        mo.assetTicker = entity.assetTicker
        mo.actionRaw = entity.action.rawValue
        mo.quantity = entity.quantity as NSDecimalNumber
        mo.pricePerUnit = entity.pricePerUnit as NSDecimalNumber
        mo.totalAmount = entity.totalAmount as NSDecimalNumber
        mo.date = entity.date
        mo.createdAt = entity.createdAt
        return mo
    }

    static func update(_ mo: TradeMO, from entity: Trade) {
        mo.assetTicker = entity.assetTicker
        mo.actionRaw = entity.action.rawValue
        mo.quantity = entity.quantity as NSDecimalNumber
        mo.pricePerUnit = entity.pricePerUnit as NSDecimalNumber
        mo.totalAmount = entity.totalAmount as NSDecimalNumber
        mo.date = entity.date
    }
}
