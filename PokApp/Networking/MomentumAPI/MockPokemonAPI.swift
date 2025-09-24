import Foundation

struct MockPokemonAPI: PokemonAPI {
    var pokemonList: () throws -> PokemonList
    var pokemon: (String) throws -> Pokemon

    init(
        pokemonList: @escaping () throws -> PokemonList,
        pokemon: @escaping (String) throws -> Pokemon
    ) {
        self.pokemonList = pokemonList
        self.pokemon = pokemon
    }

    func fetchPokemonList() async throws -> PokemonList {
        try pokemonList()
    }

    func fetchPokemon(name: String) async throws -> Pokemon {
        try pokemon(name)
    }
}
