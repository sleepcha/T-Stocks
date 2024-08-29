//
//  NetworkManagerError.swift
//  T-Stocks
//
//  Created by sleepcha on 7/15/24.
//

import Foundation

// MARK: - NetworkManagerError

enum NetworkManagerError: LocalizedError {
    case badRequest(String)
    case unauthorized(String)
    case forbidden(String)
    case notFound(String)
    case tooManyRequests(wait: TimeInterval)
    case serverError(statusCode: Int)
    case httpError(HTTPResponse)
    case networkError(Error)
    case connectionLost
    case timedOut
    case invalidResponse
    case decodingError(Error)
    case taskCancelled

    var errorDescription: String? {
        switch self {
        case .badRequest:
            String(localized: "NetworkManagerError.badRequest", defaultValue: "Запрос составлен неверно, проверьте параметры")
        case .unauthorized:
            String(localized: "NetworkManagerError.unauthorized", defaultValue: "Токен доступа не найден или не активен")
        case .forbidden:
            String(localized: "NetworkManagerError.forbidden", defaultValue: "Недостаточно прав для выполнения запроса, проверьте соответствие токена и передаваемого в запросе счета")
        case .notFound:
            String(localized: "NetworkManagerError.notFound", defaultValue: "Неверный URL запроса или переданный параметр не определен")
        case .tooManyRequests:
            String(localized: "NetworkManagerError.tooManyRequests", defaultValue: "Превышен лимит запросов в минуту")
        case .serverError(let code):
            String(localized: "NetworkManagerError.serverError", defaultValue: "Внутренняя ошибка сервера (HTTP \(code)), попробуйте повторить запрос позже")
        case .httpError(let response):
            String(localized: "NetworkManagerError.httpError", defaultValue: "Ошибка HTTP \(response.statusCode)")
        case .networkError(let error):
            String(localized: "NetworkManagerError.networkError", defaultValue: "Ошибка сети: \(error.localizedDescription)")
        case .connectionLost:
            String(localized: "NetworkManagerError.connectionLost", defaultValue: "Соединение с сервером было потеряно, попробуйте повторить запрос позже")
        case .timedOut:
            String(localized: "NetworkManagerError.timedOut", defaultValue: "Превышен лимит времени на запрос")
        case .invalidResponse:
            String(localized: "NetworkManagerError.invalidResponse", defaultValue: "Пустой или некорректный HTTP ответ")
        case .decodingError:
            String(localized: "NetworkManagerError.decodingError", defaultValue: "Не удалось декодировать объект")
        case .taskCancelled:
            String(localized: "NetworkManagerError.taskCancelled", defaultValue: "Задача была отменена")
        }
    }
}
