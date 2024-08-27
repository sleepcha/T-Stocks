import Foundation

enum HTTPClientCacheError: LocalizedError {
    case cacheMiss
    case cacheExpired

    var errorDescription: String? {
        switch self {
        case .cacheMiss:
            String(localized: "HTTPClientCacheError.cacheMiss", defaultValue: "Запрашиваемый ответ не найден в кэше")
        case .cacheExpired:
            String(localized: "HTTPClientCacheError.cacheExpired", defaultValue: "Кэшированный ответ больше не является актуальным")
        }
    }
}
