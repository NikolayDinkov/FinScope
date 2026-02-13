import SwiftUI

@main
struct FinScopeApp: App {
    @StateObject private var appCoordinator = AppCoordinator()

    init() {
        CoreDataStack.migrateStoreToAppGroupIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
                .task {
                    await CompositionRoot.shared.seedDefaultCategories()
                    await CompositionRoot.shared.seedDummyDataIfNeeded()
                    CompositionRoot.shared.marketService.start()
                    PhoneConnectivityManager.shared.activate(
                        marketService: CompositionRoot.shared.marketService
                    )
                }
        }
    }
}
