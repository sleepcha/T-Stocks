//
//  LogoRepositoryError.swift
//  T-Stocks
//
//  Created by sleepcha on 7/15/24.
//

import Foundation

// MARK: - LogoRepositoryError

enum LogoRepositoryError: LocalizedError {
    case invalidURL
    case taskCancelled
    case networkError
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            String(localized: "LogoRepositoryError.invalidURL", defaultValue: "Неверный URL")
        case .networkError:
            String(localized: "RepositoryError.networkError")
        case .serverError:
            String(localized: "RepositoryError.serverError")
        case .taskCancelled:
            String(localized: "RepositoryError.taskCancelled")
        }
    }
}

// MARK: - Error mapping

extension LogoRepositoryError {
    init(httpClientError: HTTPClientError) {
        self = switch httpClientError {
        case .networkError(let error as URLError) where error.code == .cancelled:
            .taskCancelled
        case .networkError:
            .networkError
        default:
            .serverError
        }
    }
}
