import Foundation
import CoreData

final class CoreDataPortfolioRepository: PortfolioRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Holdings

    func fetchAllHoldings() async throws -> [PortfolioHolding] {
        try await context.perform {
            let request = PortfolioHoldingMO.fetchRequest() as! NSFetchRequest<PortfolioHoldingMO>
            request.sortDescriptors = [NSSortDescriptor(key: "assetTicker", ascending: true)]
            let results = try self.context.fetch(request)
            return results.map { PortfolioHoldingMapper.toDomain($0) }
        }
    }

    func fetchHolding(byTicker ticker: String) async throws -> PortfolioHolding? {
        try await context.perform {
            let request = PortfolioHoldingMO.fetchRequest() as! NSFetchRequest<PortfolioHoldingMO>
            request.predicate = NSPredicate(format: "assetTicker == %@", ticker)
            request.fetchLimit = 1
            let results = try self.context.fetch(request)
            return results.first.map { PortfolioHoldingMapper.toDomain($0) }
        }
    }

    func createHolding(_ holding: PortfolioHolding) async throws {
        try await context.perform {
            _ = PortfolioHoldingMapper.toManagedObject(holding, context: self.context)
            try self.context.save()
        }
    }

    func updateHolding(_ holding: PortfolioHolding) async throws {
        try await context.perform {
            let request = PortfolioHoldingMO.fetchRequest() as! NSFetchRequest<PortfolioHoldingMO>
            request.predicate = NSPredicate(format: "id == %@", holding.id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            PortfolioHoldingMapper.update(mo, from: holding)
            try self.context.save()
        }
    }

    func deleteHolding(_ holding: PortfolioHolding) async throws {
        try await context.perform {
            let request = PortfolioHoldingMO.fetchRequest() as! NSFetchRequest<PortfolioHoldingMO>
            request.predicate = NSPredicate(format: "id == %@", holding.id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            self.context.delete(mo)
            try self.context.save()
        }
    }

    // MARK: - Trades

    func fetchAllTrades() async throws -> [Trade] {
        try await context.perform {
            let request = TradeMO.fetchRequest() as! NSFetchRequest<TradeMO>
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let results = try self.context.fetch(request)
            return results.map { TradeMapper.toDomain($0) }
        }
    }

    func fetchTrades(forTicker ticker: String) async throws -> [Trade] {
        try await context.perform {
            let request = TradeMO.fetchRequest() as! NSFetchRequest<TradeMO>
            request.predicate = NSPredicate(format: "assetTicker == %@", ticker)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let results = try self.context.fetch(request)
            return results.map { TradeMapper.toDomain($0) }
        }
    }

    func createTrade(_ trade: Trade) async throws {
        try await context.perform {
            _ = TradeMapper.toManagedObject(trade, context: self.context)
            try self.context.save()
        }
    }
}
