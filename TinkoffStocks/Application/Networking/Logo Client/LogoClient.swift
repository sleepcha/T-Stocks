//
//  LogoClient.swift
//  T-Stocks
//
//  Created by sleepcha on 8/8/24.
//

import Foundation

// MARK: - LogoClient

final class LogoClient: HTTPClientImpl {
    init() {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.timeoutIntervalForRequest = C.requestTimeout
        sessionConfiguration.timeoutIntervalForResource = C.resourceTimeout
        sessionConfiguration.requestCachePolicy = .useProtocolCachePolicy
        sessionConfiguration.urlCache = URLCache(
            memoryCapacity: C.cacheMemoryCapacity,
            diskCapacity: C.cacheDiskCapacity,
            diskPath: C.cacheDiskPath
        )

        super.init(
            session: URLSession(configuration: sessionConfiguration),
            configuration: HTTPClientConfiguration(baseURL: C.logoCDNURL)
        )
    }
}

// MARK: - Constants

private extension C {
    static let logoCDNURL = URL(string: "https://invest-brands.cdn-tinkoff.ru/")!
    static let requestTimeout: TimeInterval = 15
    static let resourceTimeout: TimeInterval = 60

    static let cacheMemoryCapacity = 32 * 1024 * 1024
    static let cacheDiskCapacity = 128 * 1024 * 1024
    static let cacheDiskPath = "Images"
}
