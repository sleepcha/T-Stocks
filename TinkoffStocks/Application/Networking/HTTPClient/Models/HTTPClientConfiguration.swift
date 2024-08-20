import Foundation

/// A structure used to initialize an HTTP client.
///
/// - `baseURL` will be concatenated with ``HTTPRequest/path``. The default value is `nil`.
///
/// - `allowedCharacters` is a set of characters that will not be percent-encoded in URL query parameters. `CharacterSet.urlQueryAllowed` is used as the default.
///
/// - `transformCachedRequest` gives you the opportunity to modify each request before caching it.
/// For example, remove/obfuscate headers containing private data, modify the HTTP method or the URL.
/// The closure does not influence the actual network request and is only used when `cacheMode` is set to `.manual`.
/// Make sure that the `URLRequest` remains unique in some way since it is used as a key in `URLCache`'s dictionary. Otherwise, you might end up retrieving an incorrect cached response.
struct HTTPClientConfiguration {
    let baseURL: URL?
    let allowedCharacters: CharacterSet
    let transformingCached: (URLRequest) -> URLRequest

    init(
        baseURL: URL? = nil,
        allowedCharacters: CharacterSet = .urlQueryAllowed,
        transformCachedRequest: @escaping (URLRequest) -> URLRequest = { $0 }
    ) {
        self.baseURL = baseURL
        self.allowedCharacters = allowedCharacters
        self.transformingCached = transformCachedRequest
    }
}
