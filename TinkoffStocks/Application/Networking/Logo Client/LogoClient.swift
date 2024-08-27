//
//  HTTPClientFactory+LogoClient.swift
//  T-Stocks
//
//  Created by sleepcha on 8/8/24.
//

import Foundation

// MARK: - Constants

private enum Constants {
    static let logoCDNURL: URL = "https://invest-brands.cdn-tinkoff.ru/"
    static let requestTimeout: TimeInterval = 15
    static let resourceTimeout: TimeInterval = 60

    static let cacheMemoryCapacity = 32 * 1024 * 1024
    static let cacheDiskCapacity = 128 * 1024 * 1024
    static let cacheDiskPath = "Images"
}

// MARK: - LogoClient

final class LogoClient: HTTPClientImpl {
    init() {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.timeoutIntervalForRequest = Constants.requestTimeout
        sessionConfiguration.timeoutIntervalForResource = Constants.resourceTimeout
        sessionConfiguration.requestCachePolicy = .useProtocolCachePolicy
        sessionConfiguration.urlCache = URLCache(
            memoryCapacity: Constants.cacheMemoryCapacity,
            diskCapacity: Constants.cacheDiskCapacity,
            diskPath: Constants.cacheDiskPath
        )

        super.init(
            session: URLSession(configuration: sessionConfiguration),
            configuration: HTTPClientConfiguration(baseURL: Constants.logoCDNURL)
        )
    }
}
