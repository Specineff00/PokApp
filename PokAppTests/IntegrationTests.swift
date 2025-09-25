import ComposableArchitecture
@testable import PokApp
import XCTest

@MainActor
final class IntegrationTests: XCTestCase {
    // MARK: - Full App Flow Tests

    func testCompletePokemonListFlow() async {
        let mockPokemonList = PokemonList.mock(
            results: [
                PokemonEntryPoint(name: "pikachu"),
                PokemonEntryPoint(name: "charizard"),
                PokemonEntryPoint(name: "blastoise"),
            ]
        )

        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI { mockPokemonList }
        }

        // 1. App starts and loads Pokemon list
        await store.send(.pokemonList(.view(.onAppear))) {
            $0.pokemonList.isLoading = true
            $0.pokemonList.isError = false
        }

        await store.receive(.pokemonList(.onReceivePokemonList(.success(mockPokemonList)))) {
            $0.pokemonList.isLoading = false
            $0.pokemonList.pokemonList = mockPokemonList
        }

        // 2. User taps on a Pokemon to view details
        await store.send(.pokemonList(.delegate(.onTapPokemon("pikachu")))) {
            $0.path.append(.detail(.init(name: "pikachu")))
        }

        // 3. Verify the navigation state
        XCTAssertEqual(store.state.path.count, 1)
        XCTAssertEqual(store.state.path[0], .detail(.init(name: "pikachu")))
    }

    func testMultiplePokemonNavigation() async {
        let mockPokemonList = PokemonList.mock(
            results: [
                PokemonEntryPoint(name: "pikachu"),
                PokemonEntryPoint(name: "charizard"),
                PokemonEntryPoint(name: "blastoise"),
            ]
        )

        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI { mockPokemonList }
        }

        // Load initial list
        await store.send(.pokemonList(.view(.onAppear))) {
            $0.pokemonList.isLoading = true
        }

        await store.receive(.pokemonList(.onReceivePokemonList(.success(mockPokemonList)))) {
            $0.pokemonList.isLoading = false
            $0.pokemonList.pokemonList = mockPokemonList
        }

        // Navigate to first Pokemon
        await store.send(.pokemonList(.delegate(.onTapPokemon("pikachu")))) {
            $0.path.append(.detail(.init(name: "pikachu")))
        }

        // Navigate to second Pokemon
        await store.send(.pokemonList(.delegate(.onTapPokemon("charizard")))) {
            $0.path.append(.detail(.init(name: "charizard")))
        }

        // Navigate to third Pokemon
        await store.send(.pokemonList(.delegate(.onTapPokemon("blastoise")))) {
            $0.path.append(.detail(.init(name: "blastoise")))
        }

        // Verify navigation stack
        XCTAssertEqual(store.state.path.count, 3)
        XCTAssertEqual(store.state.path[0], .detail(.init(name: "pikachu")))
        XCTAssertEqual(store.state.path[1], .detail(.init(name: "charizard")))
        XCTAssertEqual(store.state.path[2], .detail(.init(name: "blastoise")))
    }

    func testNavigationStackPopFlow() async {
        let mockPokemonList = PokemonList.mock(
            results: [
                PokemonEntryPoint(name: "pikachu"),
                PokemonEntryPoint(name: "charizard"),
            ]
        )

        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI { mockPokemonList }
        }

        // Load list
        await store.send(.pokemonList(.view(.onAppear))) {
            $0.pokemonList.isLoading = true
        }

        await store.receive(.pokemonList(.onReceivePokemonList(.success(mockPokemonList)))) {
            $0.pokemonList.isLoading = false
            $0.pokemonList.pokemonList = mockPokemonList
        }

        // Navigate to first Pokemon
        await store.send(.pokemonList(.delegate(.onTapPokemon("pikachu")))) {
            $0.path.append(.detail(.init(name: "pikachu")))
        }

        // Navigate to second Pokemon
        await store.send(.pokemonList(.delegate(.onTapPokemon("charizard")))) {
            $0.path.append(.detail(.init(name: "charizard")))
        }

        // Pop back to first Pokemon
        await store.send(.path(.popFrom(id: store.state.path.ids[1]))) {
            $0.path.removeLast()
        }

        // Pop back to root
        await store.send(.path(.popFrom(id: store.state.path.ids[0]))) {
            $0.path.removeLast()
        }

        // Should be back at root
        XCTAssertTrue(store.state.path.isEmpty)
    }

    func testRefreshFlow() async {
        let initialList = PokemonList.mock(
            results: [PokemonEntryPoint(name: "pikachu")]
        )

        let refreshedList = PokemonList.mock(
            results: [
                PokemonEntryPoint(name: "pikachu"),
                PokemonEntryPoint(name: "charizard"),
            ]
        )

        var callCount = 0
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI {
                callCount += 1
                return callCount == 1 ? initialList : refreshedList
            }
        }

        // Initial load
        await store.send(.pokemonList(.view(.onAppear))) {
            $0.pokemonList.isLoading = true
        }

        await store.receive(.pokemonList(.onReceivePokemonList(.success(initialList)))) {
            $0.pokemonList.isLoading = false
            $0.pokemonList.pokemonList = initialList
        }

        // Refresh
        await store.send(.pokemonList(.view(.onRefresh))) {
            $0.pokemonList.isLoading = true
        }

        await store.receive(.pokemonList(.onReceivePokemonList(.success(refreshedList)))) {
            $0.pokemonList.isLoading = false
            $0.pokemonList.pokemonList = refreshedList
        }

        // Verify API was called twice
        XCTAssertEqual(callCount, 2)
    }
}
