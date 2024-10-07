import Foundation

// MARK: - HTTPRequest

/// Model used for HTTP communication in ``HTTPClient``.
struct HTTPRequest {
    let method: HTTPMethod
    let path: URL
    let queryParameters: [String: String]
    let headers: [String: String]
    let body: Data?

    init(
        _ method: HTTPMethod,
        path: URL,
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.method = method
        self.path = path
        self.queryParameters = queryParameters
        self.headers = headers
        self.body = body
    }
}
