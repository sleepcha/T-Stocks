import Foundation

enum FetchError: LocalizedError {
    case emptyResponse
    case invalidHTTPResponse(URLResponse)
    case httpError(Data?, HTTPURLResponse)
    case emptyData(HTTPURLResponse)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            String(localized: "FetchError.emptyResponse", defaultValue: "Пустой ответ")
        case .invalidHTTPResponse(let response):
            String(localized: "FetchError.invalidHTTPResponse", defaultValue: "Некорректный HTTP ответ:\n\(response.debugDescription)")
        case .httpError(_, let response):
            String(localized: "FetchError.httpError", defaultValue: "Ошибка HTTP \(response.statusCode)")
        case .emptyData(let response):
            String(localized: "FetchError.emptyData", defaultValue: "Не получено данных от сервера. HTTP \(response.debugDescription)")
        case .networkError(let underlyingError):
            String(localized: "FetchError.networkError", defaultValue: "Ошибка сети: \(underlyingError.localizedDescription)")
        }
    }
}
