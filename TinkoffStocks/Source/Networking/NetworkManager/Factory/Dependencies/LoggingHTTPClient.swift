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
    private let logger = Logger(subsystem: C.ID.loggerSubsystem, category: "HTTPClient")

    init(client: HTTPClient) {
        self.httpClient = client
    }

    func fetchDataTask(
        _ httpRequest: HTTPRequest,
        cacheMode: CacheMode,
        completion: @escaping (Result<Data, HTTPClientError>) -> Void
    ) -> HTTPClientTask {
        let completion = { [logger] (result: Result<Data, HTTPClientError>) in
            switch result {
            case .success:
                logger.debug("✅ \(httpRequest.path)")
            case .failure(let error):
                logger.warning("❌ \(error.localizedDescription)\n\n\(httpRequest.path) \(httpRequest.body?.asString ?? "")")
            }
            completion(result)
        }

        return httpClient.fetchDataTask(httpRequest, cacheMode: cacheMode, completion: completion)
    }

    func cached(_ httpRequest: HTTPRequest, isValid: (Date) -> Bool) -> Result<Data, HTTPClientCacheError> {
        httpClient.cached(httpRequest, isValid: isValid)
    }

    func removeCached(_ httpRequest: HTTPRequest) {
        httpClient.removeCached(httpRequest)
    }

    func removeAllCachedResponses() {
        httpClient.removeAllCachedResponses()
    }
}

extension Data {
    var asString: String? {
        String(data: self, encoding: .utf8)
    }
}
