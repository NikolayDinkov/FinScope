import SwiftUI

final class DashboardCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()

    func start() -> some View {
        DashboardCoordinatorView(coordinator: self)
    }
}
