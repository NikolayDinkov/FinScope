import CoreData

final class CoreDataAccountRepository: AccountRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Account] {
        try await context.perform {
            let request = AccountMO.fetchRequest() as! NSFetchRequest<AccountMO>
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let results = try self.context.fetch(request)
            return results.map { AccountMapper.toDomain($0) }
        }
    }

    func fetchById(_ id: UUID) async throws -> Account? {
        try await context.perform {
            let request = AccountMO.fetchRequest() as! NSFetchRequest<AccountMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            let results = try self.context.fetch(request)
            return results.first.map { AccountMapper.toDomain($0) }
        }
    }

    func create(_ account: Account) async throws {
        try await context.perform {
            _ = AccountMapper.toManagedObject(account, context: self.context)
            try self.context.save()
        }
        NotificationCenter.default.post(name: .accountsDidChange, object: nil)
    }

    func update(_ account: Account) async throws {
        try await context.perform {
            let request = AccountMO.fetchRequest() as! NSFetchRequest<AccountMO>
            request.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            AccountMapper.update(mo, from: account)
            try self.context.save()
        }
        NotificationCenter.default.post(name: .accountsDidChange, object: nil)
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let request = AccountMO.fetchRequest() as! NSFetchRequest<AccountMO>
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let mo = try self.context.fetch(request).first else { return }
            self.context.delete(mo)
            try self.context.save()
        }
        NotificationCenter.default.post(name: .accountsDidChange, object: nil)
    }

    func hasTransactions(_ accountId: UUID) async throws -> Bool {
        try await context.perform {
            let request = TransactionMO.fetchRequest() as! NSFetchRequest<TransactionMO>
            request.predicate = NSPredicate(format: "account.id == %@", accountId as CVarArg)
            request.fetchLimit = 1
            let count = try self.context.count(for: request)
            return count > 0
        }
    }
}
