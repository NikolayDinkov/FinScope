import CoreData

final class CoreDataTransactionRepository: TransactionRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext
    private let mapper = TransactionMapper()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Transaction] {
        try await context.perform { [context, mapper] in
            let request = TransactionMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetchByAccount(_ accountId: UUID) async throws -> [Transaction] {
        try await context.perform { [context, mapper] in
            let request = TransactionMO.fetchRequest()
            request.predicate = NSPredicate(format: "account.id == %@", accountId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetchByCategory(_ categoryId: UUID) async throws -> [Transaction] {
        try await context.perform { [context, mapper] in
            let request = TransactionMO.fetchRequest()
            request.predicate = NSPredicate(format: "category.id == %@", categoryId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetchInDateRange(from: Date, to: Date) async throws -> [Transaction] {
        try await context.perform { [context, mapper] in
            let request = TransactionMO.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", from as CVarArg, to as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetch(byId id: UUID) async throws -> Transaction? {
        try await context.perform { [context, mapper] in
            let request = TransactionMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try context.fetch(request).first.map { mapper.toEntity($0) }
        }
    }

    func save(_ transaction: Transaction) async throws {
        try await context.perform { [context, mapper] in
            let request = TransactionMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                mapper.update(existing, from: transaction)
            } else {
                let mo = mapper.toManagedObject(transaction, in: context)
                // Link to account
                let accountRequest = AccountMO.fetchRequest()
                accountRequest.predicate = NSPredicate(format: "id == %@", transaction.accountId as CVarArg)
                accountRequest.fetchLimit = 1
                mo.account = try context.fetch(accountRequest).first

                // Link to category
                if let categoryId = transaction.categoryId {
                    let categoryRequest = CategoryMO.fetchRequest()
                    categoryRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
                    categoryRequest.fetchLimit = 1
                    mo.category = try context.fetch(categoryRequest).first
                }
            }
            try context.save()
        }
    }

    func saveAll(_ transactions: [Transaction]) async throws {
        try await context.perform { [context, mapper] in
            for transaction in transactions {
                let mo = mapper.toManagedObject(transaction, in: context)
                let accountRequest = AccountMO.fetchRequest()
                accountRequest.predicate = NSPredicate(format: "id == %@", transaction.accountId as CVarArg)
                accountRequest.fetchLimit = 1
                mo.account = try context.fetch(accountRequest).first
            }
            try context.save()
        }
    }

    func delete(_ transaction: Transaction) async throws {
        try await context.perform { [context] in
            let request = TransactionMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
            request.fetchLimit = 1

            if let mo = try context.fetch(request).first {
                context.delete(mo)
                try context.save()
            }
        }
    }

    func countByAccount(_ accountId: UUID) async throws -> Int {
        try await context.perform { [context] in
            let request = TransactionMO.fetchRequest()
            request.predicate = NSPredicate(format: "account.id == %@", accountId as CVarArg)
            return try context.count(for: request)
        }
    }
}
