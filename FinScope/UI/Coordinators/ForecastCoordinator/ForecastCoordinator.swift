import SwiftUI

final class ForecastCoordinator: Coordinator, ObservableObject {
    @Published var path = [NavigationDestination]()

    func start() -> some View {
        ForecastCoordinatorView(coordinator: self)
    }
}
