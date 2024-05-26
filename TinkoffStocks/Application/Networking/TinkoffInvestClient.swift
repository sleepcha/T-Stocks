//
//  TinkoffInvestClient.swift
//  BondsFilter
//
//  Created by sleepcha on 11/21/22.
//

import Fetchup
import Foundation

// MARK: - ServerEnvironment

enum ServerEnvironment: Codable {
    case prod
    case sandbox

    var url: URL {
        switch self {
        case .prod: "https://invest-public-api.tinkoff.ru"
        case .sandbox: "https://sandbox-invest-public-api.tinkoff.ru"
        }
    }
}

// MARK: - AuthData

struct AuthData: Codable {
    let token: String
    let server: ServerEnvironment
}

// MARK: - TinkoffInvestClient

final class TinkoffInvestClient: FetchupClient {
    let configuration: FetchupClientConfiguration
    let session: URLSession
    let environment: ServerEnvironment
    private var cacheMode: CacheMode
    private var expiry: Expiry?

    init(auth: AuthData) {
        let headers = [
            "Authorization": "Bearer \(auth.token)",
            "accept": "application/json",
            "Content-Type": "application/json",
            "x-app-name": "sleepcha.TinkoffStocks",
        ]

        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.httpAdditionalHeaders = headers
        urlSessionConfiguration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: Constants.urlCacheDiskCapacity)
        urlSessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        urlSessionConfiguration.networkServiceType = .responsiveData
        urlSessionConfiguration.timeoutIntervalForRequest = Constants.apiTimeoutInterval

        let hash = HashingService.getDigest(of: auth.token, using: .sha256)
        let requestTransformer = { (original: URLRequest) in
            var request = original

            // 1. A hack for caching POST requests that actually behave like GET (due to API being a gRPC-gateway).
            // URLCache won't retrieve cached responses to POST requests
            // (https://developer.apple.com/forums/thread/732010)
            request.httpMethod = HTTPMethod.get.rawValue

            // 2. Authorization header is removed to prevent storing the token as plaintext.
            request.setValue(nil, forHTTPHeaderField: "Authorization")

            // 3. A custom query item containing the hash of token will guarantee the request uniqueness for different users.
            // This is just in case - the cache must be cleared when the user logs out anyway.
            request.url = request.url?.appending([Constants.cachedResponseUserIDKey: hash], notEncoding: .rfc3986Allowed)

            return request
        }

        self.configuration = FetchupClientConfiguration(
            baseURL: auth.server.url,
            transformCachedRequest: requestTransformer
        )
        self.session = URLSession(configuration: urlSessionConfiguration)
        self.environment = auth.server
        self.cacheMode = .disabled
    }

    /// Initializes a copy of a client instance.
    private init(_ client: TinkoffInvestClient) {
        self.configuration = client.configuration
        self.session = URLSession(configuration: client.session.configuration)
        self.environment = client.environment
        self.cacheMode = client.cacheMode
    }

    /// Returns a modified instance that will cache each response with the specified expiry period.
    func caching(for period: Expiry.Period) -> TinkoffInvestClient {
        let cachingClient = TinkoffInvestClient(self)
        cachingClient.cacheMode = .manual
        cachingClient.expiry = Expiry.for(period)
        return cachingClient
    }

    /// Returns an instance of async task that will call a completion with cached resource if available (and `cacheMode` is `.expires`) or perform a network request.
    func fetch<T: APIResource>(_ resource: T, completion: @escaping ResultHandler<T.Response>) -> AsyncTask {
        AsyncTask { [self] task in
            let handleResult: ResultHandler<T.Response> = { result in
                completion(result)
                task.done(error: result.failure)
            }

            if let expiry, let cached = cached(resource, isValid: expiry.isValid) {
                handleResult(cached)
                return
            }

            let fetchTask = fetchDataTask(resource, cacheMode: cacheMode, completion: handleResult)

            guard !task.is(.cancelled) else {
                handleResult(.failure(AsyncTask.TaskError.cancelled))
                return
            }

            task.onCancel = fetchTask.cancel
            fetchTask.resume()
        }
    }
}

// MARK: - Constants

private enum Constants {
    static let cachedResponseUserIDKey = "tinkoffClientCacheID"
    static let apiTimeoutInterval: TimeInterval = 15
    static let urlCacheDiskCapacity = 512 * 1024 * 1024
    // static let rubleUID = "a92e2e25-a698-45cc-a781-167cf465257c"
}
