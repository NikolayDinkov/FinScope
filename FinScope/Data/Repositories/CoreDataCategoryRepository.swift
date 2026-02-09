import CoreData

final class CoreDataCategoryRepository: CategoryRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext
    private let mapper = CategoryMapper()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Category] {
        try await context.perform { [context, mapper] in
            let request = CategoryMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetchByType(_ type: TransactionType) async throws -> [Category] {
        try await context.perform { [context, mapper] in
            let request = CategoryMO.fetchRequest()
            request.predicate = NSPredicate(format: "type == %@", type.rawValue)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetch(byId id: UUID) async throws -> Category? {
        try await context.perform { [context, mapper] in
            let request = CategoryMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try context.fetch(request).first.map { mapper.toEntity($0) }
        }
    }

    func save(_ category: Category) async throws {
        try await context.perform { [context, mapper] in
            let request = CategoryMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                mapper.update(existing, from: category)
            } else {
                let mo = mapper.toManagedObject(category, in: context)
                if let parentId = category.parentId {
                    let parentRequest = CategoryMO.fetchRequest()
                    parentRequest.predicate = NSPredicate(format: "id == %@", parentId as CVarArg)
                    parentRequest.fetchLimit = 1
                    mo.parent = try context.fetch(parentRequest).first
                }
            }
            try context.save()
        }
    }

    func delete(_ category: Category) async throws {
        try await context.perform { [context] in
            let request = CategoryMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
            request.fetchLimit = 1

            if let mo = try context.fetch(request).first {
                context.delete(mo)
                try context.save()
            }
        }
    }
}
