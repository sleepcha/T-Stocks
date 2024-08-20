//
//  NetworkManagerAssembly.swift
//  T-Stocks
//
//  Created by sleepcha on 8/8/24.
//

import Foundation

// MARK: - NetworkManagerAssembly

protocol NetworkManagerAssembly {
    func build(token: String, isSandbox: Bool) -> NetworkManager
}

// MARK: - NetworkManagerAssemblyImpl

final class NetworkManagerAssemblyImpl: NetworkManagerAssembly {
    func build(token: String, isSandbox: Bool) -> NetworkManager {
        NetworkManagerImpl(
            client: HTTPClientFactory.create(.apiClient(token: token, isSandbox: isSandbox)),
            decoder: JSONDecoder.custom,
            rateLimitManager: RateLimitManagerImpl(dateProvider: Date.init),
            dateProvider: Date.init
        )
    }
}
