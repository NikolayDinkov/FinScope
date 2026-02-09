import CoreData

final class CoreDataInvestmentRepository: InvestmentRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext
    private let mapper = InvestmentMapper()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Investment] {
        try await context.perform { [context, mapper] in
            let request = InvestmentMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetchByPortfolio(_ portfolioId: UUID) async throws -> [Investment] {
        try await context.perform { [context, mapper] in
            let request = InvestmentMO.fetchRequest()
            request.predicate = NSPredicate(format: "portfolio.id == %@", portfolioId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetch(byId id: UUID) async throws -> Investment? {
        try await context.perform { [context, mapper] in
            let request = InvestmentMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try context.fetch(request).first.map { mapper.toEntity($0) }
        }
    }

    func save(_ investment: Investment) async throws {
        try await context.perform { [context, mapper] in
            let request = InvestmentMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", investment.id as CVarArg)
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                mapper.update(existing, from: investment)
            } else {
                let mo = mapper.toManagedObject(investment, in: context)
                let portfolioRequest = PortfolioMO.fetchRequest()
                portfolioRequest.predicate = NSPredicate(format: "id == %@", investment.portfolioId as CVarArg)
                portfolioRequest.fetchLimit = 1
                mo.portfolio = try context.fetch(portfolioRequest).first
            }
            try context.save()
        }
    }

    func delete(_ investment: Investment) async throws {
        try await context.perform { [context] in
            let request = InvestmentMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", investment.id as CVarArg)
            request.fetchLimit = 1

            if let mo = try context.fetch(request).first {
                context.delete(mo)
                try context.save()
            }
        }
    }
}
