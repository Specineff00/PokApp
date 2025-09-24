//
//  PokemonListView.swift
//  PokApp
//
//  Created by Nikash Yogesh Ramsorrun on 24/09/2025.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: PokemonListFeature.self)
struct PokemonListView: View {
    let store: StoreOf<PokemonListFeature>

    var body: some View {
        VStack {
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
        case onReceivePokemonList(TaskResult<PokemonList>)

        enum View: Equatable {
            case onAppear
            case onRefresh
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
                    state.pokemonDetailFeature = .init(name: name)
                    return .none
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

    @Dependency(\.dismiss) private var dismiss
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

@ViewAction(for: PokemonDetailFeature.self)
struct PokemonDetail {
    let store: StoreOf<PokemonDetailFeature>

    var body: some View {
        Text(store.name)
            .onAppear {
                send(.onAppear)
            }
            .refreshable {
                await send(.onRefresh)
            }
    }
}
