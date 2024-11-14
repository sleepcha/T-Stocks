//
//  LoginFlow.swift
//  T-Stocks
//
//  Created by sleepcha on 9/2/24.
//

import UIKit

final class LoginFlow: StackFlowCoordinator {
    private let authService: AuthService
    private let error: Error?

    init(authService: AuthService, showing error: Error? = nil) {
        self.authService = authService
        self.error = error
    }

    override func start() {
        pushLoginScreen()
    }

    private func pushLoginScreen() {
        let loginScreen = LoginScreenAssemblyImpl().build(authService: authService, showing: error) { [self] result in
            switch result {
            case .receivedAccounts: stop()
            }
        }
        push(screen: loginScreen)
    }
}
