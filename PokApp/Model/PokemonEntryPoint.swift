import Foundation

struct PokemonEntryPoint: Decodable, Equatable, Identifiable {
    let name: String
    var id: String { name }
}

extension PokemonEntryPoint {
    static func mock(
        name: String = "squirtle"
    ) -> Self {
        .init(name: name)
    }
}

extension [PokemonEntryPoint] {
    static var mocks: Self {
        [
            .init(name: "squirtle"),
            .init(name: "pikachu"),
            .init(name: "blastoise"),
            .init(name: "cubone"),
        ]
    }
}
