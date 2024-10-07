//
//  LoginFlow.swift
//  T-Stocks
//
//  Created by sleepcha on 9/2/24.
//

import UIKit

final class LoginFlow: StackFlowCoordinator {
    weak var navigator: UINavigationController?
    var onStopFlow: VoidHandler?

    private let authService: AuthService
    private let error: Error?
    private let onFinishLoading: VoidHandler

    init(
        authService: AuthService,
        showing error: Error? = nil,
        onFinishLoading: @escaping VoidHandler
    ) {
        self.authService = authService
        self.error = error
        self.onFinishLoading = onFinishLoading
    }

    func start() {
        pushLoginScreen()
    }

    private func pushLoginScreen() {
        let loginScreen = LoginScreenAssemblyImpl().build(authService: authService, showing: error) { [self] result in
            switch result {
            case .receivedAccounts: stopFlow()
            case .finishedLoading: onFinishLoading()
            }
        }
        push(module: loginScreen)
    }
}
