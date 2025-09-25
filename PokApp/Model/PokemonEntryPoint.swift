import Foundation

struct PokemonEntryPoint: Decodable, Equatable, Identifiable {
    let name: String
    var id: String { name }
}

extension PokemonEntryPoint {
    static func mock(
        name: String = "Squirtle"
    ) -> Self {
        .init(name: name)
    }
}

extension [PokemonEntryPoint] {
    static var mocks: Self {
        [
            .init(name: "Squirtle"),
            .init(name: "Pikachu"),
            .init(name: "Blastoise"),
            .init(name: "Cubone"),
        ]
    }
}
