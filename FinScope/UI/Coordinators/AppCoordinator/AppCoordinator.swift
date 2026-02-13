import SwiftUI

@MainActor
final class AppCoordinator: Coordinator, ObservableObject {
    private lazy var appState = AppState()

    @MainActor
    private lazy var contentCoordinator: ContentCoordinator = {
        let root = CompositionRoot.shared
        return ContentCoordinator(
            appState: appState,
            accountRepository: root.accountRepository,
            transactionRepository: root.transactionRepository,
            categoryRepository: root.categoryRepository,
            subcategoryRepository: root.subcategoryRepository,
            budgetRepository: root.budgetRepository,
            forecastService: root.forecastService
        )
    }()

    @MainActor
    func start() -> some View {
        contentCoordinator.start()
    }
}
