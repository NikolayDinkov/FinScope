import SwiftUI

final class AppCoordinator: Coordinator, ObservableObject {
    private lazy var appState = AppState()

    @MainActor
    private lazy var contentCoordinator = ContentCoordinator(appState: appState)

    @MainActor
    func start() -> some View {
        contentCoordinator.start()
    }
}
