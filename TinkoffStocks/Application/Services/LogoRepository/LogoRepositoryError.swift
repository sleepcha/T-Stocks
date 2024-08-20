//
//  LogoRepositoryError.swift
//  T-Stocks
//
//  Created by sleepcha on 7/15/24.
//

import Foundation

enum LogoRepositoryError: Error {
    case invalidURL(String)
    case networkError(Error)
    case serverError
}
