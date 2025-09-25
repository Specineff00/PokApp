import ComposableArchitecture

@Reducer
struct PokemonDetailFeature {
    @ObservableState
    struct State: Equatable {
        var name: String
        var pokemon: Pokemon?
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
        case onReceivePokemon(TaskResult<Pokemon>)
        case view(View)
        case alert(PresentationAction<Alert>)

        @CasePathable
        enum Alert {
            case okTapped
        }

        enum View: Equatable {
            case onAppear
            case onRefresh
        }
    }

    @Dependency(\.pokemonAPI) private var pokemonAPI

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear, .onRefresh:
                    state.isError = false
                    state.isLoading = true
                    return loadPokemon(name: state.name)
                }

            case let .onReceivePokemon(result):
                state.isLoading = false
                switch result {
                case let .success(pokemon):
                    state.pokemon = pokemon
                    return .none

                case .failure:
                    state.isError = true
                    state.alert = state.alertState
                    return .none
                }

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
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
