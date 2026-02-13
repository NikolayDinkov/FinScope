import SwiftUI

@main
struct FinScopeWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchTabView(
                portfolioRepository: WatchCompositionRoot.shared.portfolioRepository,
                marketService: WatchCompositionRoot.shared.marketService
            )
            .onAppear {
                WatchCompositionRoot.shared.connectivityManager.activate()
                WatchCompositionRoot.shared.marketService.start()
            }
        }
    }
}
