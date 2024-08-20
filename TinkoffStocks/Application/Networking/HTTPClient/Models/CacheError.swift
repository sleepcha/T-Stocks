import Foundation

enum CacheError: LocalizedError {
    case cacheMiss
    case cacheExpired

    var errorDescription: String? {
        switch self {
        case .cacheMiss:
            String(localized: "CacheError.cacheMiss", defaultValue: "Запрашиваемый ответ не найден в кэше")
        case .cacheExpired:
            String(localized: "CacheError.cacheExpired", defaultValue: "Кэшированный ответ больше не является актуальным")
        }
    }
}
