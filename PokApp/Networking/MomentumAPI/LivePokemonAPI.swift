import Dependencies

struct LivePokemonAPI: PokemonAPI {
    @Dependency(\.baseService) private var baseService

    func fetchPokemonList() async throws -> PokemonList {
        try await baseService.dispatch(PokemonListRequest())
    }

    func fetchPokemon(name: String) async throws -> Pokemon {
        try await baseService.dispatch(PokemonRequest(name: name))
    }
}
