//
//  LoginServiceError.swift
//  T-Stocks
//
//  Created by sleepcha on 8/6/24.
//

enum LoginServiceError: Error {
    case networkError
    case serverError
    case noAccess
    case tooManyRequests
    case decodingError
    case taskCancelled
}
