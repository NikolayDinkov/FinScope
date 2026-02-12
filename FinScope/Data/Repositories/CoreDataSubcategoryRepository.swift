import CoreData

final class CoreDataSubcategoryRepository: SubcategoryRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll(for categoryId: UUID) async throws -> [Subcategory] {
        try await context.perform {
            let request = SubcategoryMO.fetchRequest() as! NSFetchRequest<SubcategoryMO>
            request.predicate = NSPredicate(format: "category.id == %@", categoryId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let results = try self.context.fetch(request)
            return results.map { SubcategoryMapper.toDomain($0) }
        }
    }

    func fetchById(_ id: UUID) async throws -> Subcategory? {
        try await context.perform {
            let request = SubcategoryMO.fetchRequest() as! NSFetchRequest<SubcategoryMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            let results = try self.context.fetch(request)
            return results.first.map { SubcategoryMapper.toDomain($0) }
        }
    }

    func create(_ subcategory: Subcategory) async throws {
        try await context.perform {
            let mo = SubcategoryMapper.toManagedObject(subcategory, context: self.context)

            let categoryRequest = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
            categoryRequest.predicate = NSPredicate(format: "id == %@", subcategory.categoryId as CVarArg)
            categoryRequest.fetchLimit = 1
            mo.category = try self.context.fetch(categoryRequest).first

            try self.context.save()
        }
    }

    func update(_ subcategory: Subcategory) async throws {
        try await context.perform {
            let request = SubcategoryMO.fetchRequest() as! NSFetchRequest<SubcategoryMO>
            request.predicate = NSPredicate(format: "id == %@", subcategory.id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            SubcategoryMapper.update(mo, from: subcategory)
            try self.context.save()
        }
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let request = SubcategoryMO.fetchRequest() as! NSFetchRequest<SubcategoryMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            self.context.delete(mo)
            try self.context.save()
        }
    }
}
