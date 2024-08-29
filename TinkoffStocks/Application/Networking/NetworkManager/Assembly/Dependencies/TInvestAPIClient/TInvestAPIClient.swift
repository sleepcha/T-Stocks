//
//  TInvestAPIClient.swift
//  T-Stocks
//
//  Created by sleepcha on 8/8/24.
//

import Foundation

// MARK: - Constants

private enum Constants {
    static let prodURL: URL = "https://invest-public-api.tinkoff.ru/rest/"
    static let sandboxURL: URL = "https://sandbox-invest-public-api.tinkoff.ru/rest/"
    #if DEBUG
    static let requestTimeout: TimeInterval = 2
    #else
    static let requestTimeout: TimeInterval = 15
    #endif
    static let resourceTimeout: TimeInterval = 30
    static let headers = [
        "accept": "application/json",
        "Content-Type": "application/json",
        "x-app-name": "sleepcha.T-Stocks",
    ]
    static let auth = (key: "Authorization", value: "Bearer ")

    static let cacheMemoryCapacity = 32 * 1024 * 1024
    static let cacheDiskCapacity = 512 * 1024 * 1024
    static let cacheDiskPath = "API"
}

// MARK: - TInvestAPIClient

final class TInvestAPIClient: HTTPClientImpl {
    init(token: String, isSandbox: Bool) {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpAdditionalHeaders = Constants.headers
        sessionConfiguration.httpAdditionalHeaders?[Constants.auth.key] = Constants.auth.value + token
        sessionConfiguration.timeoutIntervalForRequest = Constants.requestTimeout
        sessionConfiguration.timeoutIntervalForResource = Constants.resourceTimeout
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.networkServiceType = .responsiveData
        sessionConfiguration.urlCache = URLCache(
            memoryCapacity: Constants.cacheMemoryCapacity,
            diskCapacity: Constants.cacheDiskCapacity,
            diskPath: Constants.cacheDiskPath
        )

        let requestTransformer = { (original: URLRequest) in
            var request = original

            // 1. A hack for caching POST requests that mostly behave like GET (due to API being a gRPC-gateway).
            // URLCache won't retrieve cached responses to POST requests: https://developer.apple.com/forums/thread/732010
            request.httpMethod = HTTPMethod.get.rawValue

            // 2. Authorization header is removed to prevent storing the token as plaintext.
            request.setValue(nil, forHTTPHeaderField: Constants.auth.key)

            return request
        }

        super.init(
            session: URLSession(configuration: sessionConfiguration),
            configuration: HTTPClientConfiguration(
                baseURL: isSandbox ? Constants.sandboxURL : Constants.prodURL,
                allowedCharacters: .rfc3986Allowed,
                transformCachedRequest: requestTransformer
            )
        )
    }
}

// MARK: - Helpers

private extension CharacterSet {
    private static let specialCharacters = CharacterSet(charactersIn: "-._~")
    static let rfc3986Allowed = CharacterSet.alphanumerics.union(.specialCharacters)
}
