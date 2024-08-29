//
//  NetworkManager.swift
//  TinkoffStocks
//
//  Created by sleepcha on 6/1/24.
//

import Foundation

// MARK: - Constants

private extension Int {
    static let defaultRetryCount = 2
}

// MARK: - NetworkManager

protocol NetworkManager {
    /// Returns a task that calls the completion handler with a cached response if available (and `NetworkManager` is caching) or with the result of a network request.
    func fetch<T: Endpoint>(_ endpoint: T, retryCount: Int, completion: @escaping (T.Result) -> Void) -> AsyncTask

    /// A version of the method with the default `retryCount` value.
    func fetch<T: Endpoint>(_ endpoint: T, completion: @escaping (T.Result) -> Void) -> AsyncTask

    /// Returns a modified instance that will cache each response with the specified expiry.
    func caching(_ expiry: Expiry) -> NetworkManager

    /// Removes all cached responses.
    func clearCache()
}

extension NetworkManager {
    func fetch<T: Endpoint>(_ endpoint: T, completion: @escaping (T.Result) -> Void) -> AsyncTask {
        fetch(endpoint, retryCount: .defaultRetryCount, completion: completion)
    }
}

extension Endpoint {
    typealias Result = Swift.Result<Response, NetworkManagerError>
}

// MARK: - NetworkManagerImpl

final class NetworkManagerImpl: NetworkManager {
    typealias DateProvider = () -> Date
    typealias ErrorMapper = (HTTPClientError) -> NetworkManagerError

    private let client: HTTPClient
    private let cacheExpiry: Expiry?
    private let decoder: JSONDecoder
    private let errorMapper: ErrorMapper
    private let now: DateProvider
    private let rateLimitManager: RateLimitManager

    init(
        client: HTTPClient,
        cacheExpiry: Expiry? = nil,
        decoder: JSONDecoder,
        errorMapper: @escaping ErrorMapper,
        dateProvider: @escaping DateProvider
    ) {
        self.client = client
        self.cacheExpiry = cacheExpiry
        self.decoder = decoder
        self.errorMapper = errorMapper
        self.now = dateProvider
        self.rateLimitManager = RateLimitManager(dateProvider: dateProvider)
    }

    func fetch<T: Endpoint>(_ endpoint: T, retryCount: Int, completion: @escaping (T.Result) -> Void) -> AsyncTask {
        AsyncTask { [self] task in
            let completion = { (result: T.Result) in
                completion(result)
                task.done(error: result.failure)
            }

            if let cacheExpiry, case .success(let response) = client.cached(endpoint, isValid: cacheExpiry.isValid(now())) {
                let result = response.decoded(as: T.Response.self, using: decoder).mapError(NetworkManagerError.decodingError)
                completion(result)
                return
            }

            networkFetch(endpoint, retryCount: retryCount, parentTask: task, completion: completion)
        }
    }

    func caching(_ expiry: Expiry) -> NetworkManager {
        NetworkManagerImpl(
            client: client,
            cacheExpiry: expiry,
            decoder: decoder,
            errorMapper: errorMapper,
            dateProvider: now
        )
    }

    func clearCache() {
        client.removeAllCachedResponses()
    }

    // MARK: Private

    private func networkFetch<T: Endpoint>(_ endpoint: T, retryCount: Int, parentTask: AsyncTask, completion: @escaping (T.Result) -> Void) {
        if let waitTime = rateLimitManager.getResetInterval() {
            completion(.failure(.tooManyRequests(wait: waitTime)))
            return
        }

        let cacheMode: CacheMode = (cacheExpiry == nil) ? .disabled : .manual

        let dataTask = client.fetchDataTask(endpoint, cacheMode: cacheMode) { [self] result in
            guard parentTask.state != .cancelled else {
                completion(.failure(.taskCancelled))
                return
            }

            let decodedResult = result
                .mapError(errorMapper)
                .flatMap { $0.decoded(as: T.Response.self, using: decoder).mapError(NetworkManagerError.decodingError) }

            switch decodedResult {
            case .failure(let error):
                handle(
                    error: error,
                    retryCount: retryCount,
                    completion: { completion(.failure(error)) },
                    retryHandler: { networkFetch(endpoint, retryCount: retryCount - 1, parentTask: parentTask, completion: completion) }
                )
            case .success(let response):
                completion(.success(response))
            }
        }
        parentTask.addCancellationHandler(dataTask.cancel)
        dataTask.resume()
    }

    private func handle(error: NetworkManagerError, retryCount: Int, completion: Handler, retryHandler: Handler) {
        switch error {
        case .tooManyRequests(let waitTime):
            // TODO: enqueue the task to retry after the limit reset
            rateLimitManager.setResetInterval(waitTime)
            completion()
        case .timedOut, .connectionLost, .serverError:
            retryCount > 0 ? retryHandler() : completion()
        default:
            completion()
        }
    }
}

// MARK: - Helpers

private extension Expiry {
    func isValid(_ currentDate: Date) -> (Date) -> Bool {
        { creationDate in
            let expirationDate = switch self {
            case let .for(period):
                period.expiration(for: creationDate)
            case let .until(deadline):
                deadline()
            case .forever:
                Date.distantFuture
            }
            return currentDate < expirationDate
        }
    }
}
