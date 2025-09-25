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
                        Text(pokemon.name)
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

@Reducer
struct PokemonListFeature {
    @ObservableState
    struct State: Equatable {
        var pokemonList: PokemonList?
        var pokemonDetailFeature: PokemonDetailFeature.State?
    }

    enum Action: Equatable, ViewAction {
        case view(View)
        case delegate(Delegate)
        case onReceivePokemonList(TaskResult<PokemonList>)

        enum View: Equatable {
            case onAppear
            case onRefresh
            case onTapPokemon(String)
        }

        enum Delegate: Equatable {
            case onTapPokemon(String)
        }
    }

    @Dependency(\.pokemonAPI) private var pokemonAPI

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear, .onRefresh:
                    return loadPokemonList()

                case let .onTapPokemon(name):
                    return .send(.delegate(.onTapPokemon(name)))
                }

            case let .onReceivePokemonList(result):
                switch result {
                case let .success(list):
                    print(list)
                    state.pokemonList = list
                    return .none

                case let .failure(error):
                    if let error = error as? PokAppError {
                        print(error)
                    }
                    return .none
                }

            case .delegate:
                return .none
            }
        }
    }

    private func loadPokemonList() -> EffectOf<Self> {
        .run { send in
            await send(
                .onReceivePokemonList(
                    TaskResult {
                        try await pokemonAPI.fetchPokemonList()
                    }
                )
            )
        }
    }
}
