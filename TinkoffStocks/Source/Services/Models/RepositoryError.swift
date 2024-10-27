//
//  RepositoryError.swift
//  T-Stocks
//
//  Created by sleepcha on 8/21/24.
//

import Foundation

// MARK: - RepositoryError

enum RepositoryError: LocalizedError {
    case networkError
    case serverError
    case unauthorized
    case tooManyRequests(wait: TimeInterval)
    case taskCancelled

    var errorDescription: String? {
        switch self {
        case .networkError:
            String(localized: "RepositoryError.networkError", defaultValue: "Ошибка при получении данных, проверьте ваше интернет-соединение")
        case .serverError:
            String(localized: "RepositoryError.serverError", defaultValue: "Сервис временно недоступен. Повторите, пожалуйста, позже")
        case .unauthorized:
            String(localized: "RepositoryError.unauthorized", defaultValue: "Ошибка доступа. Проверьте режим и срок действия токена")
        case .tooManyRequests:
            String(localized: "RepositoryError.tooManyRequests", defaultValue: "Превышено количество обращений к сервису. Попробуйте позже")
        case .taskCancelled:
            String(localized: "RepositoryError.taskCancelled", defaultValue: "Операция отменена")
        }
    }
}

// MARK: - Error mapping

extension RepositoryError {
    init(networkManagerError: NetworkManagerError) {
        self = switch networkManagerError {
        case .networkError, .connectionLost, .timedOut:
            .networkError
        case .badRequest, .notFound, .forbidden, .httpError, .invalidResponse, .jsonError:
            .serverError
        case .unauthorized:
            .unauthorized
        case .tooManyRequests(let waitInterval):
            .tooManyRequests(wait: waitInterval)
        }
    }
}
