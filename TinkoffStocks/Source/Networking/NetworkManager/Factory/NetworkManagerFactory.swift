//
//  NetworkManagerFactory.swift
//  T-Stocks
//
//  Created by sleepcha on 8/8/24.
//

import Foundation

// MARK: - NetworkManagerFactory

protocol NetworkManagerFactory {
    func build(token: String, isSandbox: Bool) -> NetworkManager
}

// MARK: - NetworkManagerFactoryImpl

final class NetworkManagerFactoryImpl: NetworkManagerFactory {
    func build(token: String, isSandbox: Bool) -> NetworkManager {
        let apiClient = TInvestAPIClient(token: token, isSandbox: isSandbox)
        #if DEBUG
        let client = LoggingHTTPClient(client: apiClient)
        #else
        let client = apiClient
        #endif

        return NetworkManagerImpl(
            client: client,
            encoder: JSONEncoder.custom,
            decoder: JSONDecoder.custom,
            errorMapper: HTTPClientErrorMapper.map,
            dateProvider: Date.init
        )
    }
}
