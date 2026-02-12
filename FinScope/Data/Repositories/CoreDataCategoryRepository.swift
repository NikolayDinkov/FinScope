import CoreData

final class CoreDataCategoryRepository: CategoryRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Category] {
        try await context.perform {
            let request = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let results = try self.context.fetch(request)
            return results.map { CategoryMapper.toDomain($0) }
        }
    }

    func fetchByType(_ type: TransactionType) async throws -> [Category] {
        try await context.perform {
            let request = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
            request.predicate = NSPredicate(format: "transactionTypeRaw == %@", type.rawValue)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let results = try self.context.fetch(request)
            return results.map { CategoryMapper.toDomain($0) }
        }
    }

    func fetchById(_ id: UUID) async throws -> Category? {
        try await context.perform {
            let request = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            let results = try self.context.fetch(request)
            return results.first.map { CategoryMapper.toDomain($0) }
        }
    }

    func create(_ category: Category) async throws {
        try await context.perform {
            _ = CategoryMapper.toManagedObject(category, context: self.context)
            try self.context.save()
        }
    }

    func update(_ category: Category) async throws {
        try await context.perform {
            let request = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
            request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            CategoryMapper.update(mo, from: category)
            try self.context.save()
        }
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let request = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            self.context.delete(mo)
            try self.context.save()
        }
    }

    func seedDefaultsIfNeeded(defaults: [Category]) async throws {
        try await context.perform {
            let request = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
            request.predicate = NSPredicate(format: "isDefault == YES")
            let existingCount = try self.context.count(for: request)

            guard existingCount == 0 else { return }

            for category in defaults {
                _ = CategoryMapper.toManagedObject(category, context: self.context)
            }
            try self.context.save()
        }
    }
}
