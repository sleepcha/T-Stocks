import Foundation

// MARK: - HTTPClientTaskDelegate

final class HTTPClientTaskDelegate: NSObject, URLSessionDataDelegate {
    private let cacheMode: CacheMode
    private let transformingCached: (URLRequest) -> URLRequest
    private let completionHandler: (Result<Data, HTTPClientError>) -> Void

    private var receivedData = Data()

    init(
        cacheMode: CacheMode,
        transformingCached: @escaping (URLRequest) -> URLRequest,
        completionHandler: @escaping (Result<Data, HTTPClientError>) -> Void
    ) {
        self.cacheMode = cacheMode
        self.transformingCached = transformingCached
        self.completionHandler = completionHandler
    }

    // MARK: URLSessionDataDelegate

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let result = Self.processResponse(data: receivedData, response: task.response, error: error)
        completionHandler(result)
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse,
        completionHandler: @escaping (CachedURLResponse?) -> Void
    ) {
        switch cacheMode {
        case .policy:
            completionHandler(proposedResponse)
        case .manual:
            defer { completionHandler(nil) }

            guard case .success = Self.processResponse(data: proposedResponse.data, response: proposedResponse.response, error: nil)
            else { break }

            guard var request = dataTask.currentRequest, let cache = session.configuration.urlCache
            else { break }

            request.httpBody = dataTask.originalRequest?.httpBody
            cache.storeCachedResponse(
                proposedResponse.addingTimestamp(Date()),
                for: transformingCached(request)
            )
        case .disabled:
            completionHandler(nil)
        }
    }

    // MARK: Private

    private static func processResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, HTTPClientError> {
        if let error {
            return .failure(.networkError(error))
        }

        guard let response else {
            return .failure(.emptyResponse)
        }

        guard let response = (response as? HTTPURLResponse) else {
            return .failure(.invalidHTTPResponse)
        }

        guard 200..<300 ~= response.statusCode else {
            return .failure(.httpError(HTTPResponse(response, data)))
        }

        guard let data, !data.isEmpty else {
            return .failure(.emptyData(HTTPResponse(response)))
        }

        return .success(data)
    }
}

// MARK: - Helpers

private extension HTTPResponse {
    init(_ response: HTTPURLResponse, _ data: Data? = nil) {
        self.init(
            url: response.url,
            statusCode: response.statusCode,
            headers: response.allHeaderFields.reduce(into: [:]) { $0["\($1.key)"] = "\($1.value)" },
            data: data
        )
    }
}
