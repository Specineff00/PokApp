import ComposableArchitecture

@Reducer
struct AppFeature {
    @Reducer
    enum Path {
        case detail(PokemonDetailFeature)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var pokemonList = PokemonListFeature.State()
    }

    enum Action {
        case path(StackActionOf<Path>)
        case pokemonList(PokemonListFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(
            state: \.pokemonList,
            action: \.pokemonList,
            child: PokemonListFeature.init
        )
        Reduce { state, action in
            switch action {
            case let .pokemonList(.delegate(.onTapPokemon(name))):
                state.path.append(.detail(.init(name: name)))
                return .none

            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension AppFeature.Path.State: Equatable {}
