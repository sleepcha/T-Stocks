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
        let apiClient = TInvestAPIClient(token: token, isSandbox: isSandbox)
        #if DEBUG
        let client = LoggingHTTPClient(client: apiClient)
        #else
        let client = apiClient
        #endif

        return NetworkManagerImpl(
            client: client,
            decoder: JSONDecoder.custom,
            errorMapper: HTTPClientErrorMapper.map,
            dateProvider: Date.init
        )
    }
}
