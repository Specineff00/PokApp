import ComposableArchitecture

@Reducer
struct PokemonListFeature {
    @ObservableState
    struct State: Equatable {
        var pokemonList: PokemonList?
        var pokemonDetailFeature: PokemonDetailFeature.State?
        var isLoading = false
        var isError = false
        @Presents var alert: AlertState<Action.Alert>?

        var alertState: AlertState<Action.Alert> {
            AlertState {
                TextState("Woops")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("something went wrong!")
            }
        }
    }

    enum Action: Equatable, ViewAction {
        case view(View)
        case delegate(Delegate)
        case onReceivePokemonList(TaskResult<PokemonList>)
        case alert(PresentationAction<Alert>)

        @CasePathable
        enum Alert {
            case okTapped
        }

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
                    state.isLoading = true
                    state.isError = false
                    return loadPokemonList()

                case let .onTapPokemon(name):
                    return .send(.delegate(.onTapPokemon(name)))
                }

            case let .onReceivePokemonList(result):
                state.isLoading = false
                switch result {
                case let .success(list):
                    state.pokemonList = list
                    return .none

                case .failure:
                    state.alert = state.alertState
                    state.isError = true
                    return .none
                }

            case .delegate, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
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
