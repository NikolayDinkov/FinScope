import CoreData

final class CoreDataTransactionRepository: TransactionRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionMO.fetchRequest() as! NSFetchRequest<TransactionMO>
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let results = try self.context.fetch(request)
            return results.map { TransactionMapper.toDomain($0) }
        }
    }

    func fetchAll(for accountId: UUID) async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionMO.fetchRequest() as! NSFetchRequest<TransactionMO>
            request.predicate = NSPredicate(format: "account.id == %@ OR destinationAccount.id == %@", accountId as CVarArg, accountId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let results = try self.context.fetch(request)
            return results.map { TransactionMapper.toDomain($0) }
        }
    }

    func fetchById(_ id: UUID) async throws -> Transaction? {
        try await context.perform {
            let request = TransactionMO.fetchRequest() as! NSFetchRequest<TransactionMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            let results = try self.context.fetch(request)
            return results.first.map { TransactionMapper.toDomain($0) }
        }
    }

    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        try await context.perform {
            let request = TransactionMO.fetchRequest() as! NSFetchRequest<TransactionMO>
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let results = try self.context.fetch(request)
            return results.map { TransactionMapper.toDomain($0) }
        }
    }

    func create(_ transaction: Transaction) async throws {
        try await context.perform {
            let mo = TransactionMapper.toManagedObject(transaction, context: self.context)

            let accountRequest = AccountMO.fetchRequest() as! NSFetchRequest<AccountMO>
            accountRequest.predicate = NSPredicate(format: "id == %@", transaction.accountId as CVarArg)
            accountRequest.fetchLimit = 1
            mo.account = try self.context.fetch(accountRequest).first

            if let categoryId = transaction.categoryId {
                let categoryRequest = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
                categoryRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
                categoryRequest.fetchLimit = 1
                mo.category = try self.context.fetch(categoryRequest).first
            }

            if let subcategoryId = transaction.subcategoryId {
                let subRequest = SubcategoryMO.fetchRequest() as! NSFetchRequest<SubcategoryMO>
                subRequest.predicate = NSPredicate(format: "id == %@", subcategoryId as CVarArg)
                subRequest.fetchLimit = 1
                mo.subcategory = try self.context.fetch(subRequest).first
            }

            if let destinationAccountId = transaction.destinationAccountId {
                let destRequest = AccountMO.fetchRequest() as! NSFetchRequest<AccountMO>
                destRequest.predicate = NSPredicate(format: "id == %@", destinationAccountId as CVarArg)
                destRequest.fetchLimit = 1
                mo.destinationAccount = try self.context.fetch(destRequest).first
            }

            try self.context.save()
        }
    }

    func update(_ transaction: Transaction) async throws {
        try await context.perform {
            let request = TransactionMO.fetchRequest() as! NSFetchRequest<TransactionMO>
            request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            TransactionMapper.update(mo, from: transaction)

            if let categoryId = transaction.categoryId {
                let categoryRequest = CategoryMO.fetchRequest() as! NSFetchRequest<CategoryMO>
                categoryRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
                categoryRequest.fetchLimit = 1
                mo.category = try self.context.fetch(categoryRequest).first
            } else {
                mo.category = nil
            }

            if let subcategoryId = transaction.subcategoryId {
                let subRequest = SubcategoryMO.fetchRequest() as! NSFetchRequest<SubcategoryMO>
                subRequest.predicate = NSPredicate(format: "id == %@", subcategoryId as CVarArg)
                subRequest.fetchLimit = 1
                mo.subcategory = try self.context.fetch(subRequest).first
            } else {
                mo.subcategory = nil
            }

            if let destinationAccountId = transaction.destinationAccountId {
                let destRequest = AccountMO.fetchRequest() as! NSFetchRequest<AccountMO>
                destRequest.predicate = NSPredicate(format: "id == %@", destinationAccountId as CVarArg)
                destRequest.fetchLimit = 1
                mo.destinationAccount = try self.context.fetch(destRequest).first
            } else {
                mo.destinationAccount = nil
            }

            try self.context.save()
        }
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let request = TransactionMO.fetchRequest() as! NSFetchRequest<TransactionMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            self.context.delete(mo)
            try self.context.save()
        }
    }
}
