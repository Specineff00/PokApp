import ComposableArchitecture
import SwiftUI

@ViewAction(for: PokemonDetailFeature.self)
struct PokemonDetailView: View {
    @Bindable var store: StoreOf<PokemonDetailFeature>

    var body: some View {
        ScrollView {
            VStack {
                Text(store.name.capitalized)
                    .font(.headline)
                    .padding()

                if store.isError {
                    Text("Could not load! Pull to refresh!")
                } else {
                    store.pokemon.map(pokemonStats(_:))
                }
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

    private func pokemonStats(_ pokemon: Pokemon) -> some View {
        Group {
            HStack {
                VStack {
                    Text("default")
                    AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { phase in
                        phase.image?
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    }
                }

                VStack {
                    Text("SHINY!!!")
                    AsyncImage(url: URL(string: pokemon.sprites.frontShiny)) { phase in
                        phase.image?
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    }
                }
            }

            ForEach(pokemon.types) { elementalType in
                Text(elementalType.type.name.capitalized)
            }
        }
    }
}
