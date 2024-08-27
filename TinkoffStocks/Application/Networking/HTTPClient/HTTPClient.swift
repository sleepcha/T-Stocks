import Foundation

// MARK: - HTTPClient

protocol HTTPClient {
    /// Asynchronously fetches an HTTP resource using `URLSession` and passes the result to a completion handler.
    ///
    /// - Parameters:
    ///     - httpRequest: An instance that contains the data for generating a URLRequest.
    ///     - cacheMode: Specifies the way responses will be cached.
    ///     - completion: A completion handler that passes data in case of `.success`.
    ///     Otherwise `.failure(HTTPClientError)` is passed.
    func fetchDataTask(
        _ httpRequest: some HTTPRequest,
        cacheMode: CacheMode,
        completion: @escaping (Result<Data, HTTPClientError>) -> Void
    ) -> URLSessionDataTask

    /// Returns a cached version of the response.
    /// In case of failure `CacheError` is returned.
    ///
    /// If `shouldInvalidateExpiredCache` is set to true, expired responses will be automatically removed.
    ///
    /// - Parameters:
    ///     - httpRequest: An instance that contains the data used as a key to look up in the cache.
    ///     - isValid: A closure that checks whether the cached version has expired, given the creation date of the response.
    func cached(_ httpRequest: some HTTPRequest, isValid: (Date) -> Bool) -> Result<Data, CacheError>

    /// Removes a cached entry if there is one.
    func removeCached(_ httpRequest: some HTTPRequest)

    /// Clears the cache entirely.
    func removeAllCachedResponses()
}

// MARK: - HTTPClientImpl

class HTTPClientImpl: HTTPClient {
    let session: URLSession
    let configuration: HTTPClientConfiguration

    init(session: URLSession, configuration: HTTPClientConfiguration) {
        self.session = session
        self.configuration = configuration
    }

    func fetchDataTask(
        _ httpRequest: some HTTPRequest,
        cacheMode: CacheMode,
        completion: @escaping (Result<Data, HTTPClientError>) -> Void
    ) -> URLSessionDataTask {
        let request = generateURLRequest(for: httpRequest)
        let task = session.dataTask(with: request)
        task.delegate = HTTPClientTaskDelegate(
            cacheMode: cacheMode,
            transformingCached: configuration.transformingCached,
            completionHandler: completion
        )
        return task
    }

    func cached(_ httpRequest: some HTTPRequest, isValid: (Date) -> Bool) -> Result<Data, CacheError> {
        let request = generateURLRequest(for: httpRequest, transformForCaching: true)

        guard let urlCache = session.configuration.urlCache,
              let cachedResponse = urlCache.cachedResponse(for: request),
              let timestamp = cachedResponse.timestamp
        else {
            return .failure(.cacheMiss)
        }

        guard isValid(timestamp) else {
            urlCache.removeCachedResponse(for: request)
            return .failure(.cacheExpired)
        }

        return .success(cachedResponse.data)
    }

    func removeCached(_ httpRequest: some HTTPRequest) {
        let request = generateURLRequest(for: httpRequest, transformForCaching: true)
        session.configuration.urlCache?.removeCachedResponse(for: request)
    }

    func removeAllCachedResponses() {
        session.configuration.urlCache?.removeAllCachedResponses()
    }

    // MARK: Private

    private func generateURLRequest(for httpRequest: some HTTPRequest, transformForCaching: Bool = false) -> URLRequest {
        let url = URL(
            string: httpRequest.path.absoluteString,
            relativeTo: configuration.baseURL
        )!.appending(
            httpRequest.queryParameters,
            notEncoding: configuration.allowedCharacters
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpRequest.method.rawValue
        urlRequest.httpBody = httpRequest.body
        httpRequest.headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.configure?(&urlRequest)

        return transformForCaching ? configuration.transformingCached(urlRequest) : urlRequest
    }
}

// MARK: - URL+Extension

private extension URL {
    func appending(_ queryParameters: [String: String], notEncoding allowedCharacters: CharacterSet) -> URL {
        guard !queryParameters.isEmpty else { return self }

        let queryItems = queryParameters
            .mapValues { $0.addingPercentEncoding(withAllowedCharacters: allowedCharacters) }
            .map(URLQueryItem.init)

        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        components.percentEncodedQueryItems = components.percentEncodedQueryItems ?? []
        components.percentEncodedQueryItems?.append(contentsOf: queryItems)
        return components.url!
    }
}
