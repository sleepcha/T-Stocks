//
//  SandboxServiceError.swift
//  T-Stocks
//
//  Created by sleepcha on 8/12/24.
//

enum SandboxServiceError: Error {
    case networkError
    case serverError
    case noAccess
    case tooManyRequests
    case decodingError
    case taskCancelled
}
