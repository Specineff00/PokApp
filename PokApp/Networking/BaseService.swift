import Foundation

protocol BaseServiceProtocol {
    var baseURL: String { get }
    func dispatch<R: Request>(_ request: R) async throws -> R.ReturnType
}

actor LiveBaseService: BaseServiceProtocol {
    let baseURL: String

    init(baseURL: String = "https://pokeapi.co/api/v2") {
        self.baseURL = baseURL
    }

    func dispatch<R>(_ request: R) async throws -> R.ReturnType where R: Request {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            throw PokAppError.badRequest
        }

        let (data, _) = try await URLSession.shared.data(for: urlRequest)

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(R.ReturnType.self, from: data)
        } catch {
            throw PokAppError.decodeError
        }
    }
}

struct MockBaseService: BaseServiceProtocol {
    var baseURL: String = "baseurl.com"
    var dispatchHandler: (Any) throws -> Any

    init(dispatchHandler: @escaping (Any) throws -> Any) {
        self.dispatchHandler = dispatchHandler
    }

    func dispatch<R>(_ request: R) async throws -> R.ReturnType where R: Request {
        let result = try dispatchHandler(request)
        guard let returnValue = result as? R.ReturnType else {
            throw NSError(domain: "MockAPIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Type mismatch"])
        }
        return returnValue
    }
}
