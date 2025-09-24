import Dependencies
import Foundation

extension DependencyValues {
    var pokemonAPI: any PokemonAPI {
        get { self[PokemonAPIKey.self] }
        set { self[PokemonAPIKey.self] = newValue }
    }
}

private enum PokemonAPIKey: DependencyKey {
    static let liveValue: any PokemonAPI = LivePokemonAPI()
    static let testValue: any PokemonAPI = MockPokemonAPI {
        .mock()
    } pokemon: { _ in
        .mock()
    }

    static var previewValue: any PokemonAPI = MockPokemonAPI {
        .mock()
    } pokemon: { _ in
        .mock()
    }
}
