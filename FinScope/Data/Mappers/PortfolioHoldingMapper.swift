import Foundation
import CoreData

struct PortfolioHoldingMapper {
    static func toDomain(_ mo: PortfolioHoldingMO) -> PortfolioHolding {
        PortfolioHolding(
            id: mo.id ?? UUID(),
            assetTicker: mo.assetTicker ?? "",
            quantity: mo.quantity as? Decimal ?? 0,
            averageCostBasis: mo.averageCostBasis as? Decimal ?? 0,
            createdAt: mo.createdAt ?? Date(),
            updatedAt: mo.updatedAt ?? Date()
        )
    }

    static func toManagedObject(_ entity: PortfolioHolding, context: NSManagedObjectContext) -> PortfolioHoldingMO {
        let mo = PortfolioHoldingMO(context: context)
        mo.id = entity.id
        mo.assetTicker = entity.assetTicker
        mo.quantity = entity.quantity as NSDecimalNumber
        mo.averageCostBasis = entity.averageCostBasis as NSDecimalNumber
        mo.createdAt = entity.createdAt
        mo.updatedAt = entity.updatedAt
        return mo
    }

    static func update(_ mo: PortfolioHoldingMO, from entity: PortfolioHolding) {
        mo.assetTicker = entity.assetTicker
        mo.quantity = entity.quantity as NSDecimalNumber
        mo.averageCostBasis = entity.averageCostBasis as NSDecimalNumber
        mo.updatedAt = entity.updatedAt
    }
}
