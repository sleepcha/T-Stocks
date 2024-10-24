//
//  NetworkManager.swift
//  TinkoffStocks
//
//  Created by sleepcha on 6/1/24.
//

import Foundation

// MARK: - NetworkManager

protocol NetworkManager {
    /// Returns a task that calls the completion handler with a cached response if available (and `NetworkManager` is caching) or with the result of a network request.
    func fetch<T: Endpoint>(_ endpoint: T, retryCount: Int) -> AsyncTask<T.Response, NetworkManagerError>

    /// A version of the method with the default `retryCount` value.
    func fetch<T: Endpoint>(_ endpoint: T) -> AsyncTask<T.Response, NetworkManagerError>

    /// Returns a modified instance that will cache each response with the specified expiry.
    func caching(_ expiry: Expiry) -> NetworkManager

    /// Removes all cached responses.
    func clearCache()
}

extension NetworkManager {
    func fetch<T: Endpoint>(_ endpoint: T) -> AsyncTask<T.Response, NetworkManagerError> {
        fetch(endpoint, retryCount: C.Defaults.retryCount)
    }
}

// MARK: - NetworkManagerImpl

final class NetworkManagerImpl: NetworkManager {
    typealias ErrorMapper = (HTTPClientError) -> NetworkManagerError
    typealias DateProvider = () -> Date

    private let client: HTTPClient
    private let cacheExpiry: Expiry?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let errorMapper: ErrorMapper
    private let now: DateProvider
    private let rateLimitManager: RateLimitManager

    init(
        client: HTTPClient,
        cacheExpiry: Expiry? = nil,
        encoder: JSONEncoder,
        decoder: JSONDecoder,
        errorMapper: @escaping ErrorMapper,
        dateProvider: @escaping DateProvider
    ) {
        self.client = client
        self.cacheExpiry = cacheExpiry
        self.encoder = encoder
        self.decoder = decoder
        self.errorMapper = errorMapper
        self.now = dateProvider
        self.rateLimitManager = RateLimitManager(dateProvider: dateProvider)
    }

    func fetch<T: Endpoint>(_ endpoint: T, retryCount: Int) -> AsyncTask<T.Response, NetworkManagerError> {
        AsyncTask(label: "fetch:\(endpoint.path)") { [self] task in
            let request: HTTPRequest

            switch createHTTPRequest(with: endpoint) {
            case .success(let httpRequest):
                request = httpRequest
            case .failure(let error):
                #if DEBUG
                print("Unable to encode endpoint:", error)
                #endif
                task.done(.failure(.jsonError(error)))
                return
            }

            if let cacheExpiry, case .success(let response) = client.cached(request, isValid: cacheExpiry.isValid(now())) {
                let result = response
                    .decoded(as: T.Response.self, using: decoder)
                    .mapError(NetworkManagerError.jsonError)
                task.done(result)
                return
            }

            networkFetch(request, attempts: (left: retryCount, max: retryCount), parentTask: task)
        }
    }

    func caching(_ expiry: Expiry) -> NetworkManager {
        NetworkManagerImpl(
            client: client,
            cacheExpiry: expiry,
            encoder: encoder,
            decoder: decoder,
            errorMapper: errorMapper,
            dateProvider: now
        )
    }

    func clearCache() {
        client.removeAllCachedResponses()
    }

    private func createHTTPRequest<T: Endpoint>(with endpoint: T) -> Result<HTTPRequest, Error> {
        switch endpoint {
        case let endpoint as any POSTEndpoint:
            Result {
                try encoder.encode(endpoint.request)
            }.map {
                HTTPRequest(.post, path: endpoint.path, body: $0)
            }
        default:
            .success(HTTPRequest(.get, path: endpoint.path))
        }
    }

    private func networkFetch<Response: Decodable>(
        _ httpRequest: HTTPRequest,
        attempts: (left: Int, max: Int),
        parentTask: AsyncTask<Response, NetworkManagerError>
    ) {
        if let waitTime = rateLimitManager.getResetInterval() {
            parentTask.done(.failure(.tooManyRequests(wait: waitTime)))
            return
        }

        let cacheMode: CacheMode = (cacheExpiry == nil) ? .disabled : .manual

        let dataTask = client.fetchDataTask(httpRequest, cacheMode: cacheMode) { [self] result in
            guard !parentTask.isCancelled else { return }

            let decodedResult = result
                .mapError(errorMapper)
                .flatMap { $0.decoded(as: Response.self, using: decoder).mapError(NetworkManagerError.jsonError) }

            switch decodedResult {
            case .failure(let error):
                handle(
                    error: error,
                    attempts: attempts,
                    completion: { parentTask.done(.failure(error)) },
                    retryHandler: {
                        let attemptsLeft = (left: attempts.left - 1, max: attempts.max)
                        self.networkFetch(httpRequest, attempts: attemptsLeft, parentTask: parentTask)
                    }
                )
            case .success(let response):
                parentTask.done(.success(response))
            }
        }
        parentTask.onCancel(dataTask.cancel)
        dataTask.resume()
    }

    private func handle(error: NetworkManagerError, attempts: (left: Int, max: Int), completion: VoidHandler, retryHandler: @escaping VoidHandler) {
        switch error {
        case .tooManyRequests(let waitTime):
            // TODO: enqueue the task to retry after the limit reset?
            rateLimitManager.setResetInterval(waitTime)
            completion()
        case .timedOut, .connectionLost:
            attempts.left > 0 ? retryHandler() : completion()
        case .httpError(let response) where 500...599 ~= response.statusCode:
            if attempts.left > 0 {
                let attempt = attempts.max - attempts.left
                let delay = maxBackoffJitter(attempt: attempt)
                DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: retryHandler)
            } else {
                completion()
            }
        default:
            completion()
        }
    }

    /// Returns the value of max exponential backoff with jitter in seconds.
    private func maxBackoffJitter(attempt: Int) -> TimeInterval {
        let base: TimeInterval = 1
        let maxDelay: TimeInterval = 10
        let exponential = base * pow(2, Double(attempt))
        return TimeInterval.random(in: 0...min(exponential, maxDelay))
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
                deadline
            }
            return currentDate < expirationDate
        }
    }
}
