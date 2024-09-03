//
//  TInvestAPIClient.swift
//  T-Stocks
//
//  Created by sleepcha on 8/8/24.
//

import Foundation

// MARK: - Constants

private extension C {
    static let prodURL: URL = "https://invest-public-api.tinkoff.ru/rest/"
    static let sandboxURL: URL = "https://sandbox-invest-public-api.tinkoff.ru/rest/"
    #if DEBUG
    static let requestTimeout: TimeInterval = 1
    #else
    static let requestTimeout: TimeInterval = 15
    #endif
    static let resourceTimeout: TimeInterval = 30
    static let headers = [
        "accept": "application/json",
        "Content-Type": "application/json",
        "x-app-name": ID.appNameHeader,
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
        sessionConfiguration.httpAdditionalHeaders = C.headers
        sessionConfiguration.httpAdditionalHeaders?[C.auth.key] = C.auth.value + token
        sessionConfiguration.timeoutIntervalForRequest = C.requestTimeout
        sessionConfiguration.timeoutIntervalForResource = C.resourceTimeout
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.networkServiceType = .responsiveData
        sessionConfiguration.urlCache = URLCache(
            memoryCapacity: C.cacheMemoryCapacity,
            diskCapacity: C.cacheDiskCapacity,
            diskPath: C.cacheDiskPath
        )

        let requestTransformer = { (original: URLRequest) in
            var request = original

            // 1. A hack for caching POST requests that mostly behave like GET (due to API being a gRPC-gateway).
            // URLCache won't retrieve cached responses to POST requests: https://developer.apple.com/forums/thread/732010
            request.httpMethod = HTTPMethod.get.rawValue

            // 2. Authorization header is removed to prevent storing the token as plaintext.
            request.setValue(nil, forHTTPHeaderField: C.auth.key)

            return request
        }

        super.init(
            session: URLSession(configuration: sessionConfiguration),
            configuration: HTTPClientConfiguration(
                baseURL: isSandbox ? C.sandboxURL : C.prodURL,
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
