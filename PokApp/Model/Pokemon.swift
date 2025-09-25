import Foundation

struct Pokemon: Decodable, Equatable {
    let name: String
    let types: [ElementalType]
    let sprites: Sprites
}

extension Pokemon {
    static func mock(
        name: String = "Pikachu",
        types: [ElementalType] = [.init(type: .init(name: "Electric", url: "URL"))],
        sprites: Sprites = .init(frontDefault: "default", frontShiny: "shiny")
    ) -> Self {
        .init(
            name: name,
            types: types,
            sprites: sprites
        )
    }
}

struct PokemonRequest: Request {
    typealias ReturnType = Pokemon
    let path: String

    init(name: String) {
        path = "/pokemon/\(name)"
    }
}
