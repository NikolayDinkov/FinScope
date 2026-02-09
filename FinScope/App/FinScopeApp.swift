import SwiftUI

@main
struct FinScopeApp: App {
    @State private var compositionRoot = CompositionRoot()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: compositionRoot.appCoordinator)
        }
    }
}
