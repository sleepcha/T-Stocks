//
//  LogoRepositoryError.swift
//  T-Stocks
//
//  Created by sleepcha on 7/15/24.
//

import Foundation

// MARK: - LogoRepositoryError

enum LogoRepositoryError: Error {
    case invalidURL
    case networkError
    case serverError
    case invalidImage
}

// MARK: - Error mapping

extension LogoRepositoryError {
    init(httpClientError: HTTPClientError) {
        self = switch httpClientError {
        case .networkError:
            .networkError
        default:
            .serverError
        }
    }
}
