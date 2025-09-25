import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        NavigationStack(
            path: $store.scope(
                state: \.path,
                action: \.path
            )
        ) {
            PokemonListView(
                store: store.scope(
                    state: \.pokemonList,
                    action: \.pokemonList
                )
            )
        } destination: { store in
            switch store.case {
            case let .detail(store):
                PokemonDetailView(store: store)
            }
        }
    }
}
