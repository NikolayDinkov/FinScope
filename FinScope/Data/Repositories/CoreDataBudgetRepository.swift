import CoreData

final class CoreDataBudgetRepository: BudgetRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext
    private let mapper = BudgetMapper()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Budget] {
        try await context.perform { [context, mapper] in
            let request = BudgetMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetchByUser(_ userId: UUID) async throws -> [Budget] {
        try await context.perform { [context, mapper] in
            let request = BudgetMO.fetchRequest()
            request.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetch(byId id: UUID) async throws -> Budget? {
        try await context.perform { [context, mapper] in
            let request = BudgetMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try context.fetch(request).first.map { mapper.toEntity($0) }
        }
    }

    func save(_ budget: Budget) async throws {
        try await context.perform { [context, mapper] in
            let request = BudgetMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", budget.id as CVarArg)
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                mapper.update(existing, from: budget)
            } else {
                let mo = mapper.toManagedObject(budget, in: context)
                let userRequest = UserMO.fetchRequest()
                userRequest.predicate = NSPredicate(format: "id == %@", budget.userId as CVarArg)
                userRequest.fetchLimit = 1
                mo.user = try context.fetch(userRequest).first
            }
            try context.save()
        }
    }

    func delete(_ budget: Budget) async throws {
        try await context.perform { [context] in
            let request = BudgetMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", budget.id as CVarArg)
            request.fetchLimit = 1

            if let mo = try context.fetch(request).first {
                context.delete(mo)
                try context.save()
            }
        }
    }
}
