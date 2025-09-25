import Foundation

enum PokAppError: Error {
    case badRequest
    case decodeError
    case load(Error)
}

extension PokAppError: Equatable {
    static func == (lhs: PokAppError, rhs: PokAppError) -> Bool {
        switch (lhs, rhs) {
        case (.badRequest, .badRequest):
            return true
        case (.decodeError, .decodeError):
            return true
        case let (.load(lhsError), .load(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
