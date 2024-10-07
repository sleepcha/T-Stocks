//
//  SandboxServiceFactory.swift
//  T-Stocks
//
//  Created by sleepcha on 8/16/24.
//

import Foundation

// MARK: - SandboxServiceFactory

protocol SandboxServiceFactory {
    func build(networkManager: NetworkManager) -> SandboxService
}

// MARK: - SandboxServiceFactoryImpl

final class SandboxServiceFactoryImpl: SandboxServiceFactory {
    func build(networkManager: NetworkManager) -> SandboxService {
        SandboxServiceImpl(networkManager: networkManager)
    }
}
