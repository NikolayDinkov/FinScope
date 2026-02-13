import CoreData

final class CoreDataBudgetRepository: BudgetRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Budget] {
        try await context.perform {
            let request = BudgetMO.fetchRequest() as! NSFetchRequest<BudgetMO>
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            let results = try self.context.fetch(request)
            return results.map { BudgetMapper.toDomain($0) }
        }
    }

    func fetchById(_ id: UUID) async throws -> Budget? {
        try await context.perform {
            let request = BudgetMO.fetchRequest() as! NSFetchRequest<BudgetMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            let results = try self.context.fetch(request)
            return results.first.map { BudgetMapper.toDomain($0) }
        }
    }

    func create(_ budget: Budget) async throws {
        try await context.perform {
            let mo = BudgetMapper.toManagedObject(budget, context: self.context)

            let categoryRequest = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
            categoryRequest.predicate = NSPredicate(format: "id == %@", budget.categoryId as CVarArg)
            categoryRequest.fetchLimit = 1
            mo.category = try self.context.fetch(categoryRequest).first

            try self.context.save()
        }
    }

    func update(_ budget: Budget) async throws {
        try await context.perform {
            let request = BudgetMO.fetchRequest() as! NSFetchRequest<BudgetMO>
            request.predicate = NSPredicate(format: "id == %@", budget.id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            BudgetMapper.update(mo, from: budget)

            let categoryRequest = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
            categoryRequest.predicate = NSPredicate(format: "id == %@", budget.categoryId as CVarArg)
            categoryRequest.fetchLimit = 1
            mo.category = try self.context.fetch(categoryRequest).first

            try self.context.save()
        }
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let request = BudgetMO.fetchRequest() as! NSFetchRequest<BudgetMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            self.context.delete(mo)
            try self.context.save()
        }
    }
}
