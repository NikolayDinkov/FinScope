import CoreData

final class CoreDataStack: @unchecked Sendable {
    static let shared = CoreDataStack()

    static let appGroupIdentifier = "group.com.finscope.shared"

    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "FinScope")

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        } else if let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier
        ) {
            let storeURL = containerURL.appendingPathComponent("FinScope.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            persistentContainer.persistentStoreDescriptions = [description]
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load CoreData store: \(error)")
            }
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: persistentContainer.viewContext,
            queue: .main
        ) { _ in
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
        }
    }

    static func migrateStoreToAppGroupIfNeeded() {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else { return }

        let destinationURL = containerURL.appendingPathComponent("FinScope.sqlite")

        // Already migrated
        guard !FileManager.default.fileExists(atPath: destinationURL.path) else { return }

        // Find old store in default Application Support directory
        guard let appSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return }

        let sourceURL = appSupportURL.appendingPathComponent("FinScope.sqlite")
        guard FileManager.default.fileExists(atPath: sourceURL.path) else { return }

        let suffixes = ["", "-shm", "-wal"]
        for suffix in suffixes {
            let srcPath = sourceURL.path + suffix
            let dstPath = destinationURL.path + suffix

            guard FileManager.default.fileExists(atPath: srcPath) else { continue }
            do {
                try FileManager.default.copyItem(atPath: srcPath, toPath: dstPath)
            } catch {
                print("Failed to migrate CoreData store file \(suffix): \(error)")
            }
        }
    }

    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Failed to save CoreData context: \(error)")
            }
        }
    }
}
