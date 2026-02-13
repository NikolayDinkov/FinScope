import Foundation
import CoreData

@MainActor
final class WatchCompositionRoot {
    static let shared = WatchCompositionRoot()

    let coreDataStack: CoreDataStack
    let portfolioRepository: PortfolioRepositoryProtocol
    let connectivityManager: WatchConnectivityManager
    let marketService: WatchMarketService

    private init() {
        coreDataStack = CoreDataStack()
        let context = coreDataStack.viewContext
        portfolioRepository = CoreDataPortfolioRepository(context: context)
        connectivityManager = WatchConnectivityManager.shared
        marketService = WatchMarketService(connectivityManager: connectivityManager)
    }
}
