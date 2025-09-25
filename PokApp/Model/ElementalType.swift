import Foundation

struct ElementalType: Decodable, Equatable, Identifiable {
    let type: Species
    var id: String { type.name }
}
