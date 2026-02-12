import SwiftUI

final class InvestmentsCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()

    func start() -> some View {
        InvestmentsCoordinatorView(coordinator: self)
    }
}
