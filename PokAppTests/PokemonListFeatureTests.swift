import ComposableArchitecture
@testable import PokApp
import XCTest

@MainActor
final class PokemonListFeatureTests: XCTestCase {
    func testInitialState() {
        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        }

        XCTAssertNil(store.state.pokemonList)
        XCTAssertFalse(store.state.isLoading)
        XCTAssertFalse(store.state.isError)
        XCTAssertNil(store.state.alert)
    }

    // MARK: - Action Tests

    func testOnAppearStartsLoading() async {
        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI()
        }

        await store.send(.view(.onAppear)) {
            $0.isLoading = true
            $0.isError = false
        }

        await store.receive(.onReceivePokemonList(.success(.mock()))) {
            $0.isLoading = false
            $0.pokemonList = .mock()
        }
    }

    func testOnRefreshStartsLoading() async {
        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI()
        }

        await store.send(.view(.onRefresh)) {
            $0.isLoading = true
            $0.isError = false
        }

        await store.receive(.onReceivePokemonList(.success(.mock()))) {
            $0.isLoading = false
            $0.pokemonList = .mock()
        }
    }

    func testOnTapPokemonSendsDelegateAction() async {
        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        }

        await store.send(.view(.onTapPokemon("pikachu")))

        await store.receive(.delegate(.onTapPokemon("pikachu")))
    }

    // MARK: - Success Scenarios

    func testSuccessfulPokemonListLoad() async {
        let mockPokemonList = PokemonList.mock(
            results: [
                PokemonEntryPoint(name: "pikachu"),
                PokemonEntryPoint(name: "charizard"),
            ]
        )

        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI { mockPokemonList }
        }

        await store.send(.view(.onAppear)) {
            $0.isLoading = true
            $0.isError = false
        }

        await store.receive(.onReceivePokemonList(.success(mockPokemonList))) {
            $0.isLoading = false
            $0.pokemonList = mockPokemonList
        }
    }

    // MARK: - Error Scenarios

    func testFailedPokemonListLoadShowsAlert() async {
        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI { throw PokAppError.decodeError }
        }

        await store.send(.view(.onAppear)) {
            $0.isLoading = true
            $0.isError = false
        }

        await store.receive(.onReceivePokemonList(.failure(PokAppError.decodeError))) {
            $0.isLoading = false
            $0.isError = true
            $0.alert = $0.alertState
        }
    }

    func testAlertDismissal() async {
        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI { throw PokAppError.decodeError }
        }

        // First trigger an error to show alert
        await store.send(.view(.onAppear)) {
            $0.isLoading = true
            $0.isError = false
        }

        await store.receive(.onReceivePokemonList(.failure(PokAppError.decodeError))) {
            $0.isLoading = false
            $0.isError = true
            $0.alert = $0.alertState
        }

        // Then dismiss the alert
        await store.send(.alert(.presented(.okTapped))) {
            $0.alert = nil
        }
    }

    // MARK: - State Transitions

    func testMultipleRefreshCalls() async {
        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI()
        }

        // First refresh
        await store.send(.view(.onRefresh)) {
            $0.isLoading = true
            $0.isError = false
        }

        await store.receive(.onReceivePokemonList(.success(.mock()))) {
            $0.isLoading = false
            $0.pokemonList = .mock()
        }

        // Second refresh
        await store.send(.view(.onRefresh)) {
            $0.isLoading = true
            $0.isError = false
        }

        await store.receive(.onReceivePokemonList(.success(.mock()))) {
            $0.isLoading = false
            $0.pokemonList = .mock()
        }
    }

    func testLoadingStateTransitions() async {
        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI()
        }

        // Initial state
        XCTAssertFalse(store.state.isLoading)

        // Start loading
        await store.send(.view(.onAppear)) {
            $0.isLoading = true
        }

        // Finish loading
        await store.receive(.onReceivePokemonList(.success(.mock()))) {
            $0.pokemonList = .mock()
            $0.isLoading = false
        }
    }

    func testErrorStateTransitions() async {
        let store = TestStore(initialState: PokemonListFeature.State()) {
            PokemonListFeature()
        } withDependencies: {
            $0.pokemonAPI = MockPokemonAPI { throw PokAppError.decodeError }
        }

        // Initial state
        XCTAssertFalse(store.state.isError)

        // Trigger error
        await store.send(.view(.onAppear)) {
            $0.isLoading = true
            $0.isError = false
        }

        await store.receive(.onReceivePokemonList(.failure(PokAppError.decodeError))) {
            $0.isLoading = false
            $0.isError = true
            $0.alert = $0.alertState
        }

        // Retry after error
        await store.send(.view(.onRefresh)) {
            $0.isLoading = true
            $0.isError = false
        }

        await store.receive(.onReceivePokemonList(.failure(PokAppError.decodeError))) {
            $0.isLoading = false
            $0.isError = true
            $0.alert = $0.alertState
        }
    }
}
