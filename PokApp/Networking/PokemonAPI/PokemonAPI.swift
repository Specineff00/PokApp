import Dependencies

protocol PokemonAPI {
    func fetchPokemonList() async throws -> PokemonList // Currently only 20 limit needs expansion
    func fetchPokemon(name: String) async throws -> Pokemon
}
