import Foundation

// MARK: - HTTPRequest

/// Protocol used for HTTP communication in ``HTTPClient``.
///
/// `body` parameter represents the data passed to `URLRequest` message body.
protocol HTTPRequest {
    var method: HTTPMethod { get }
    var path: URL { get }
    var queryParameters: [String: String] { get }
    var headers: [String: String] { get }
    var body: Data? { get }

    /// Allows to set some additional `URLRequest` properties (like `timeoutInterval`) before creating a data task.
    var configure: ((inout URLRequest) -> Void)? { get }
}

extension HTTPRequest {
    var queryParameters: [String: String] { [:] }
    var headers: [String: String] { [:] }
    var body: Data? { nil }
    var configure: ((inout URLRequest) -> Void)? { nil }
}

// MARK: - GET

/// Example of a basic GET request.
struct GET: HTTPRequest {
    let method: HTTPMethod = .get
    let path: URL

    init(_ path: URL) { self.path = path }
}
