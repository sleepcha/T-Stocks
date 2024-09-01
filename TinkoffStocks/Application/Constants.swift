//
//  Constants.swift
//  T-Stocks
//
//  Created by sleepcha on 8/13/24.
//

/// A global namespace for constants.
public enum C {
    public enum ErrorMessages {
        static let networkError = String(localized: "Constants.Errors.networkError", defaultValue: "Проверьте ваше интернет-соединение")
        static let noAccessMessage = String(localized: "Constants.Errors.noAccess", defaultValue: "Ошибка доступа.\nПроверьте режим и срок действия токена")
        static let tooManyRequests = String(localized: "Constants.Errors.tooManyRequests", defaultValue: "Слишком много запросов.\nПопробуйте позже")
        static let taskCancelled = String(localized: "Constants.Errors.taskCancelled", defaultValue: "Операция отменена")
        static let serverError = String(localized: "Constants.Errors.serverError", defaultValue: "Ошибка сервера.\nПопробуйте позже")
        static let unknownError = String(localized: "Constants.Errors.unknownError", defaultValue: "Неизвестная ошибка")
    }

    public enum Keys {
        static let authTokenKeychain = "authToken"
    }
}
