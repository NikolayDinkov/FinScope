import CoreData

final class CoreDataUserRepository: UserRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext
    private let mapper = UserMapper()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetch(byId id: UUID) async throws -> User? {
        try await context.perform { [context, mapper] in
            let request = UserMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try context.fetch(request).first.map { mapper.toEntity($0) }
        }
    }

    func fetchAll() async throws -> [User] {
        try await context.perform { [context, mapper] in
            let request = UserMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func save(_ user: User) async throws {
        try await context.perform { [context, mapper] in
            let request = UserMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                mapper.update(existing, from: user)
            } else {
                _ = mapper.toManagedObject(user, in: context)
            }
            try context.save()
        }
    }

    func delete(_ user: User) async throws {
        try await context.perform { [context] in
            let request = UserMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
            request.fetchLimit = 1

            if let mo = try context.fetch(request).first {
                context.delete(mo)
                try context.save()
            }
        }
    }
}
