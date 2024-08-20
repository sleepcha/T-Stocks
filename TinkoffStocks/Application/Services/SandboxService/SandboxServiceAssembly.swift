//
//  SandboxServiceAssembly.swift
//  T-Stocks
//
//  Created by sleepcha on 8/16/24.
//

import Foundation

// MARK: - SandboxServiceAssembly

protocol SandboxServiceAssembly {
    func build(networkManager: NetworkManager) -> SandboxService
}

// MARK: - SandboxServiceAssemblyImpl

final class SandboxServiceAssemblyImpl: SandboxServiceAssembly {
    func build(networkManager: NetworkManager) -> SandboxService {
        SandboxServiceImpl(networkManager: networkManager)
    }
}
