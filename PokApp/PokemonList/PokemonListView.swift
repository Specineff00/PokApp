import ComposableArchitecture
import SwiftUI

@ViewAction(for: PokemonListFeature.self)
struct PokemonListView: View {
    @Bindable var store: StoreOf<PokemonListFeature>

    var body: some View {
        List {
            Text("Pokemon!!")
            
            if store.isError {
                Text("Could not load! Pull to refresh!")
            } else {
                store.pokemonList.map { list in
                    ForEach(list.results) { pokemon in
                        Button(action: {
                            send(.onTapPokemon(pokemon.name))
                        }) {
                            Text(pokemon.name.capitalized)
                        }
                    }
                }
            }
        }
        .overlay {
            if store.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            send(.onAppear)
        }
        .refreshable {
            send(.onRefresh)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
