//
//  HTTPClientImpl.swift
//  T-Stocks
//
//  Created by sleepcha on 8/10/24.
//

import Foundation

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
    ) -> HTTPClientTask {
        let request = generateURLRequest(for: httpRequest)
        let task = session.dataTask(with: request)
        task.delegate = HTTPClientTaskDelegate(
            cacheMode: cacheMode,
            transformingCached: configuration.transformingCached,
            completionHandler: completion
        )
        return task
    }

    func cached(_ httpRequest: some HTTPRequest, isValid: (Date) -> Bool) -> Result<Data, HTTPClientCacheError> {
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

// MARK: - URLSessionDataTask + HTTPClientTask

extension URLSessionDataTask: HTTPClientTask {}
