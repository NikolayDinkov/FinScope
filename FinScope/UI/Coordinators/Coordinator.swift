import SwiftUI

protocol Coordinator {
    associatedtype Content: View
    @MainActor func start() -> Content
}
