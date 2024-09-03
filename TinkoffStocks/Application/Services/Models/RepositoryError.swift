//
//  RepositoryError.swift
//  T-Stocks
//
//  Created by sleepcha on 8/21/24.
//

import Foundation

typealias RepositoryResult<T> = Result<T, RepositoryError>

// MARK: - RepositoryError

enum RepositoryError: LocalizedError {
    case networkError
    case serverError
    case noAccess
    case tooManyRequests
    case taskCancelled

    var errorDescription: String? {
        switch self {
        case .networkError:
            String(localized: "RepositoryError.networkError", defaultValue: "Проверьте ваше интернет-соединение")
        case .serverError:
            String(localized: "RepositoryError.serverError", defaultValue: "Ошибка сервера.\nПопробуйте позже")
        case .noAccess:
            String(localized: "RepositoryError.noAccess", defaultValue: "Ошибка доступа.\nПроверьте режим и срок действия токена")
        case .tooManyRequests:
            String(localized: "RepositoryError.tooManyRequests", defaultValue: "Слишком много запросов.\nПопробуйте позже")
        case .taskCancelled:
            String(localized: "RepositoryError.taskCancelled", defaultValue: "Операция отменена")
        }
    }
}

// MARK: - Error mapping

extension RepositoryError {
    init(_ networkManagerError: NetworkManagerError) {
        self = switch networkManagerError {
        case .networkError, .connectionLost, .timedOut:
            .networkError
        case .badRequest, .notFound, .httpError, .invalidResponse, .decodingError:
            .serverError
        case .unauthorized, .forbidden:
            .noAccess
        case .tooManyRequests:
            .tooManyRequests
        case .taskCancelled:
            .taskCancelled
        }
    }
}
