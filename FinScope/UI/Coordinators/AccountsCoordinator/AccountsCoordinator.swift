import SwiftUI

final class AccountsCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()

    func start() -> some View {
        AccountsCoordinatorView(coordinator: self)
    }
}
