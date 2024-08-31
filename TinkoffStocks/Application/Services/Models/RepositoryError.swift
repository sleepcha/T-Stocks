//
//  RepositoryError.swift
//  T-Stocks
//
//  Created by sleepcha on 8/21/24.
//

import Foundation

typealias RepositoryResult<T> = Result<T, RepositoryError>

// MARK: - RepositoryError

enum RepositoryError: Error {
    case networkError
    case serverError
    case noAccess
    case tooManyRequests
    case decodingError
    case taskCancelled
}

// MARK: - Error mapping

extension RepositoryError {
    init(_ networkManagerError: NetworkManagerError) {
        self = switch networkManagerError {
        case .networkError, .connectionLost, .timedOut:
            .networkError
        case .badRequest, .notFound, .httpError, .invalidResponse:
            .serverError
        case .unauthorized, .forbidden:
            .noAccess
        case .tooManyRequests:
            .tooManyRequests
        case .decodingError:
            .decodingError
        case .taskCancelled:
            .taskCancelled
        }
    }
}
