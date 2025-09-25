import Foundation

struct Pokemon: Decodable, Equatable {
    let name: String
    let types: [ElementalType]
}

extension Pokemon {
    static func mock(
        name: String = "Pikachu",
        types: [ElementalType] = [.init(name: "Electric")]
    ) -> Self {
        .init(
            name: name,
            types: types
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
