import ComposableArchitecture

@Reducer
struct PokemonDetailFeature {
    @ObservableState
    struct State: Equatable {
        var name: String
        var pokemon: Pokemon?
    }

    enum Action: Equatable, ViewAction {
        case onBackTapped
        case onReceivePokemon(TaskResult<Pokemon>)
        case view(View)

        enum View: Equatable {
            case onAppear
            case onRefresh
        }
    }

    @Dependency(\.pokemonAPI) private var pokemonAPI

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onBackTapped:
                return .none

            case let .view(viewAction):
                switch viewAction {
                case .onAppear, .onRefresh:
                    return loadPokemon(name: state.name)
                }

            case let .onReceivePokemon(result):
                switch result {
                case let .success(pokemon):
                    print(pokemon)
                    state.pokemon = pokemon
                    return .none

                case let .failure(error):
                    if let error = error as? PokAppError {
                        print(error)
                    }
                    return .none
                }
            }
        }
    }

    private func loadPokemon(name: String) -> EffectOf<Self> {
        .run { send in
            await send(
                .onReceivePokemon(
                    TaskResult {
                        try await pokemonAPI.fetchPokemon(name: name)
                    }
                )
            )
        }
    }
}
