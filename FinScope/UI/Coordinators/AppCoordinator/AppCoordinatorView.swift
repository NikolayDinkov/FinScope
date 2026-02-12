import SwiftUI

struct AppCoordinatorView: View {
    @StateObject var coordinator: AppCoordinator

    var body: some View {
        coordinator.start()
    }
}
