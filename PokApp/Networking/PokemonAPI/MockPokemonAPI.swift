import Foundation

struct MockPokemonAPI: PokemonAPI {
    let pokemonListResult: () throws -> PokemonList
    let pokemonResult: (String) throws -> Pokemon

    init(
        pokemonList: @escaping () throws -> PokemonList = { .mock() },
        pokemon: @escaping (String) throws -> Pokemon = { _ in .mock() }
    ) {
        pokemonListResult = pokemonList
        pokemonResult = pokemon
    }

    func fetchPokemonList() async throws -> PokemonList {
        try pokemonListResult()
    }

    func fetchPokemon(name: String) async throws -> Pokemon {
        try pokemonResult(name)
    }
}
