import Foundation

enum HTTPClientError: LocalizedError {
    case emptyResponse
    case invalidHTTPResponse
    case httpError(HTTPResponse)
    case emptyData(HTTPResponse)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            String(localized: "HTTPClientError.emptyResponse", defaultValue: "Пустой ответ")
        case .invalidHTTPResponse:
            String(localized: "HTTPClientError.invalidHTTPResponse", defaultValue: "Некорректный HTTP ответ")
        case .httpError(let response):
            String(localized: "HTTPClientError.httpError", defaultValue: "Ошибка \(response.description)")
        case .emptyData(let response):
            String(localized: "HTTPClientError.emptyData", defaultValue: "Не получено данных от сервера. \(response.description)")
        case .networkError(let underlyingError):
            String(localized: "HTTPClientError.networkError", defaultValue: "Ошибка сети: \(underlyingError.localizedDescription)")
        }
    }
}
