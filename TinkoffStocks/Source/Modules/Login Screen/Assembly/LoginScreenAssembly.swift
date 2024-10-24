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
        let view = LoginScreenVC()
        let presenter = LoginScreenPresenterImpl(
            view: WeakRefMainQueueProxy(view),
            outputHandler: outputHandler,
            authService: authService,
            showing: error
        )
        view.presenter = presenter
        return view
    }
}

// MARK: - WeakRefMainQueueProxy + LoginScreenView

extension WeakRefMainQueueProxy: LoginScreenView where View: LoginScreenView {
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
