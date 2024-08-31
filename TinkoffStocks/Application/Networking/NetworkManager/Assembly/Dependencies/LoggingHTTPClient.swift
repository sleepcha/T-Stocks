//
//  LoggingHTTPClient.swift
//  T-Stocks
//
//  Created by sleepcha on 8/28/24.
//

import OSLog

// MARK: - LoggingHTTPClient

final class LoggingHTTPClient: HTTPClient {
    private let httpClient: HTTPClient
    private let logger = Logger(subsystem: "com.sleepcha.T-Stocks", category: "NetworkManager")

    init(client: HTTPClient) {
        self.httpClient = client
    }

    func fetchDataTask(
        _ httpRequest: some HTTPRequest,
        cacheMode: CacheMode,
        completion: @escaping (Result<Data, HTTPClientError>) -> Void
    ) -> HTTPClientTask {
        let completion = { (result: Result<Data, HTTPClientError>) in
            if case .failure(let error) = result {
                self.logger.debug("❌ \(error.errorDescription ?? "")")
            }
            completion(result)
        }

        return httpClient.fetchDataTask(httpRequest, cacheMode: cacheMode, completion: completion)
    }

    func cached(_ httpRequest: some HTTPRequest, isValid: (Date) -> Bool) -> Result<Data, HTTPClientCacheError> {
        httpClient.cached(httpRequest, isValid: isValid)
    }

    func removeCached(_ httpRequest: some HTTPRequest) {
        httpClient.removeCached(httpRequest)
    }

    func removeAllCachedResponses() {
        httpClient.removeAllCachedResponses()
    }
}
