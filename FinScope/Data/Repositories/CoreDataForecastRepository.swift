import CoreData

final class CoreDataForecastRepository: ForecastRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext
    private let mapper = ForecastMapper()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Forecast] {
        try await context.perform { [context, mapper] in
            let request = ForecastMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetchByUser(_ userId: UUID) async throws -> [Forecast] {
        try await context.perform { [context, mapper] in
            let request = ForecastMO.fetchRequest()
            request.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            return try context.fetch(request).map { mapper.toEntity($0) }
        }
    }

    func fetch(byId id: UUID) async throws -> Forecast? {
        try await context.perform { [context, mapper] in
            let request = ForecastMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try context.fetch(request).first.map { mapper.toEntity($0) }
        }
    }

    func save(_ forecast: Forecast) async throws {
        try await context.perform { [context, mapper] in
            let request = ForecastMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", forecast.id as CVarArg)
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                mapper.update(existing, from: forecast)
            } else {
                let mo = mapper.toManagedObject(forecast, in: context)
                let userRequest = UserMO.fetchRequest()
                userRequest.predicate = NSPredicate(format: "id == %@", forecast.userId as CVarArg)
                userRequest.fetchLimit = 1
                mo.user = try context.fetch(userRequest).first
            }
            try context.save()
        }
    }

    func delete(_ forecast: Forecast) async throws {
        try await context.perform { [context] in
            let request = ForecastMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", forecast.id as CVarArg)
            request.fetchLimit = 1

            if let mo = try context.fetch(request).first {
                context.delete(mo)
                try context.save()
            }
        }
    }
}
