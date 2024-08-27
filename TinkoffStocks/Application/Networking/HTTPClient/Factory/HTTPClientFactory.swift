//
//  HTTPClientFactory.swift
//  T-Stocks
//
//  Created by sleepcha on 8/2/24.
//

import Foundation

enum HTTPClientFactory {
    enum HTTPClientType {
        case apiClient(token: String, isSandbox: Bool)
        case logoClient
    }

    static func create(_ type: HTTPClientType) -> HTTPClient {
        switch type {
        case let .apiClient(token, isSandbox):
            TInvestAPIClient(token: token, isSandbox: isSandbox)
        case .logoClient:
            createLogoClient()
        }
    }
}
