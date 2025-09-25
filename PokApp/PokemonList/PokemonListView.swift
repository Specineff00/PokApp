import ComposableArchitecture
import SwiftUI

@ViewAction(for: PokemonListFeature.self)
struct PokemonListView: View {
    let store: StoreOf<PokemonListFeature>

    var body: some View {
        List {
            Text("Pokemon!!")

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
        .onAppear {
            send(.onAppear)
        }
        .refreshable {
            send(.onRefresh)
        }
    }
}
