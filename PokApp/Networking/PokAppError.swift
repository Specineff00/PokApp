import Foundation

enum PokAppError: Error {
    case badRequest
    case decodeError
    case load(Error)
}
