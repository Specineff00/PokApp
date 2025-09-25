import ComposableArchitecture
import SwiftUI

@ViewAction(for: PokemonDetailFeature.self)
struct PokemonDetailView: View {
    let store: StoreOf<PokemonDetailFeature>

    var body: some View {
        ScrollView {
            VStack {
                Text(store.name.capitalized)
                    .font(.headline)
                    .padding()

                store.pokemon.map { pokemon in
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
        }
        .onAppear {
            send(.onAppear)
        }
        .refreshable {
            send(.onRefresh)
        }
    }
}
