//
//  LoginScreenAssembly.swift
//  TinkoffStocks
//
//  Created by sleepcha on 8/20/24.
//

import UIKit

// MARK: - LoginScreenAssembly

protocol LoginScreenAssembly {
    func build(authService: AuthService, showing error: Error?, outputHandler: @escaping Handler<LoginScreenOutput>) -> UIViewController
}

// MARK: - LoginScreenAssemblyImpl

final class LoginScreenAssemblyImpl: LoginScreenAssembly {
    func build(authService: AuthService, showing error: Error?, outputHandler: @escaping Handler<LoginScreenOutput>) -> UIViewController {
        let loginVC = LoginViewController()
        let presenter = LoginPresenterImpl(
            view: WeakRefMainQueueProxy(loginVC),
            outputHandler: outputHandler,
            authService: authService,
            showing: error
        )
        loginVC.presenter = presenter
        return loginVC
    }
}

// MARK: - WeakRefMainQueueProxy + LoginView

extension WeakRefMainQueueProxy: LoginView where Subject: LoginView {
    func switchState(isLoading: Bool) {
        dispatch { $0.switchState(isLoading: isLoading) }
    }

    func highlightInvalidToken() {
        dispatch { $0.highlightInvalidToken() }
    }

    func showErrorMessage(message: String) {
        dispatch { $0.showErrorMessage(message: message) }
    }

    func showHelpDialog(_ dialog: Dialog) {
        dispatch { $0.showHelpDialog(dialog) }
    }

    func openURL(_ url: URL) {
        dispatch { $0.openURL(url) }
    }
}
