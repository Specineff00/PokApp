import Foundation

protocol Request {
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: String { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Codable? { get }
    var headers: [String: String]? { get }
    associatedtype ReturnType: Decodable
}

extension Request {
    var method: HTTPMethod { return .get }
    var contentType: String { return "application/json" }
    var queryItems: [URLQueryItem]? { return nil }
    var body: Codable? { return nil }
    var headers: [String: String]? { return nil }
}

extension Request {
    private func requestBodyFrom(params: Codable?) -> Data? {
        guard let params else { return nil }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let httpBody = try? encoder.encode(params) else {
            return nil
        }

        return httpBody
    }

    func asURLRequest(baseURL: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        urlComponents.path = urlComponents.path + path
        urlComponents.queryItems = queryItems
        guard let finalURL = urlComponents.url else { return nil }
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = requestBodyFrom(params: body)

        var finalHeaders = ["Content-Type": contentType]
        headers.map { finalHeaders.merge($0) { _, new in new } }

        request.allHTTPHeaderFields = finalHeaders
        return request
    }
}
