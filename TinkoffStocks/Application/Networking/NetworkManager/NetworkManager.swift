//
//  NetworkManager.swift
//  TinkoffStocks
//
//  Created by sleepcha on 6/1/24.
//

import Foundation

// MARK: - Constants

private enum Constants {
    static let defaultRetryCount = 2
    static let defaultRateLimitReset: TimeInterval = 60
}

private extension String {
    static let rateLimitResetHeader = "x-ratelimit-reset"
    static let grpcMessageHeader = "grpc-trailer-message"
}

// MARK: - NetworkManager

protocol NetworkManager {
    /// Returns a task that calls the completion handler on the main queue with a cached response if available (and `NetworkManager` is caching) or with the result of a network request.
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
        fetch(endpoint, retryCount: Constants.defaultRetryCount, completion: completion)
    }
}

extension Endpoint {
    typealias Result = Swift.Result<Response, NetworkManagerError>
}

// MARK: - NetworkManagerImpl

final class NetworkManagerImpl: NetworkManager {
    typealias DateProvider = () -> Date

    private let client: HTTPClient
    private let cacheExpiry: Expiry?
    private let decoder: JSONDecoder
    private let rateLimitManager: RateLimitManager
    private let now: DateProvider

    init(
        client: HTTPClient,
        cacheExpiry: Expiry? = nil,
        decoder: JSONDecoder,
        rateLimitManager: RateLimitManager,
        dateProvider: @escaping DateProvider
    ) {
        self.client = client
        self.cacheExpiry = cacheExpiry
        self.decoder = decoder
        self.rateLimitManager = rateLimitManager
        self.now = dateProvider
    }

    func fetch<T: Endpoint>(_ endpoint: T, retryCount: Int, completion: @escaping (T.Result) -> Void) -> AsyncTask {
        AsyncTask { [self] task in
            let completion = { (result: T.Result) in
                DispatchQueue.mainSync { completion(result) }
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
        NetworkManagerImpl(client: client, cacheExpiry: expiry, decoder: decoder, rateLimitManager: rateLimitManager, dateProvider: now)
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
                .mapError(NetworkManagerError.init)
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
        #if DEBUG
            print("> NetworkManagerError: \(error)")
        #endif

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

// MARK: - Error mapping

private extension NetworkManagerError {
    static func processHTTPResponse(_ response: HTTPURLResponse) -> NetworkManagerError {
        var rateLimitReset: TimeInterval? { response.value(forHTTPHeaderField: .rateLimitResetHeader).flatMap(TimeInterval.init) }
        var message: String { response.value(forHTTPHeaderField: .grpcMessageHeader) ?? "" }

        return switch response.statusCode {
        case 400: .badRequest(message)
        case 401: .unauthorized(message)
        case 403: .forbidden(message)
        case 404: .notFound(message)
        case 429: .tooManyRequests(wait: rateLimitReset ?? Constants.defaultRateLimitReset)
        case 500...599: .serverError(statusCode: response.statusCode)
        default: .httpError(response)
        }
    }

    init(fetchError: FetchError) {
        self = switch fetchError {
        case .emptyResponse, .invalidHTTPResponse, .emptyData:
            .invalidResponse
        case .httpError(_, let response):
            Self.processHTTPResponse(response)
        case .networkError(let urlError as URLError) where urlError.code == .timedOut:
            .timedOut
        case .networkError(let urlError as URLError) where urlError.code == .networkConnectionLost:
            .connectionLost
        case .networkError(let error):
            .networkError(error)
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
