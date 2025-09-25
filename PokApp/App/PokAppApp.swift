import ComposableArchitecture
import SwiftUI

@main
struct PokAppApp: App {
    @MainActor
    static let store = Store(
        initialState: AppFeature.State(),
        reducer: AppFeature.init
    )
    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
