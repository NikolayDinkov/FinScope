import CoreData

final class CoreDataAccountRepository: AccountRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext
    private let mapper = AccountMapper()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Account] {
        try await context.perform { [context, mapper] in
            let request = AccountMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetchByUser(_ userId: UUID) async throws -> [Account] {
        try await context.perform { [context, mapper] in
            let request = AccountMO.fetchRequest()
            request.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetch(byId id: UUID) async throws -> Account? {
        try await context.perform { [context, mapper] in
            let request = AccountMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try context.fetch(request).first.map { mapper.toEntity($0) }
        }
    }

    func save(_ account: Account) async throws {
        try await context.perform { [context, mapper] in
            let request = AccountMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                mapper.update(existing, from: account)
            } else {
                let mo = mapper.toManagedObject(account, in: context)
                // Link to user
                let userRequest = UserMO.fetchRequest()
                userRequest.predicate = NSPredicate(format: "id == %@", account.userId as CVarArg)
                userRequest.fetchLimit = 1
                mo.user = try context.fetch(userRequest).first
            }
            try context.save()
        }
    }

    func delete(_ account: Account) async throws {
        try await context.perform { [context] in
            let request = AccountMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)
            request.fetchLimit = 1

            if let mo = try context.fetch(request).first {
                context.delete(mo)
                try context.save()
            }
        }
    }
}
