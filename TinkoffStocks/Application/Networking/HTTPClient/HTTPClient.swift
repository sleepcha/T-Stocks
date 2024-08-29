import Foundation

// MARK: - HTTPClientTask

protocol HTTPClientTask {
    func resume()
    func cancel()
}

// MARK: - HTTPClient

protocol HTTPClient {
    /// Asynchronously fetches an HTTP resource and passes the result to a completion handler.
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
    ) -> HTTPClientTask

    /// Returns a cached version of the response.
    /// In case of failure `CacheError` is returned.
    ///
    /// If `shouldInvalidateExpiredCache` is set to true, expired responses will be automatically removed.
    ///
    /// - Parameters:
    ///     - httpRequest: An instance that contains the data used as a key to look up in the cache.
    ///     - isValid: A closure that checks whether the cached version has expired, given the creation date of the response.
    func cached(_ httpRequest: some HTTPRequest, isValid: (Date) -> Bool) -> Result<Data, HTTPClientCacheError>

    /// Removes a cached entry if there is one.
    func removeCached(_ httpRequest: some HTTPRequest)

    /// Clears the cache entirely.
    func removeAllCachedResponses()
}
