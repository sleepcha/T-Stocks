//
//  HTTPClientErrorMapper.swift
//  T-Stocks
//
//  Created by sleepcha on 8/27/24.
//

import Foundation

// MARK: - Constants

private enum Constants {
    static let defaultRateLimitReset: TimeInterval = 60
}

private extension String {
    static let rateLimitResetHeader = "x-ratelimit-reset"
    static let grpcMessageHeader = "grpc-trailer-message"
}

// MARK: - HTTPClientErrorMapper

enum HTTPClientErrorMapper {
    static func map(httpClientError: HTTPClientError) -> NetworkManagerError {
        switch httpClientError {
        case .emptyResponse, .invalidHTTPResponse, .emptyData:
            .invalidResponse
        case .httpError(let response):
            Self.processHTTPResponse(response)
        case .networkError(let urlError as URLError) where urlError.code == .timedOut:
            .timedOut
        case .networkError(let urlError as URLError) where urlError.code == .networkConnectionLost:
            .connectionLost
        case .networkError(let error):
            .networkError(error)
        }
    }

    private static func processHTTPResponse(_ response: HTTPResponse) -> NetworkManagerError {
        var rateLimitReset: TimeInterval? { response.headers[.rateLimitResetHeader].flatMap(TimeInterval.init) }
        var message: String { response.headers[.grpcMessageHeader] ?? "" }

        return switch response.statusCode {
        case 400: .badRequest(message)
        case 401: .unauthorized(message)
        case 403: .forbidden(message)
        case 404: .notFound(message)
        case 429: .tooManyRequests(wait: rateLimitReset ?? Constants.defaultRateLimitReset)
        default: .httpError(response)
        }
    }
}
