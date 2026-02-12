import SwiftUI

final class BudgetCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()

    func start() -> some View {
        BudgetCoordinatorView(coordinator: self)
    }
}
