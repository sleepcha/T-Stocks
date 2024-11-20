//
//  LoginPresenterImpl.swift
//  TinkoffStocks
//
//  Created by sleepcha on 8/20/24.
//

import Foundation

// MARK: - LoginScreenOutput

enum LoginScreenOutput {
    case receivedAccounts([AccountData])
}

// MARK: - LoginPresenterImpl

final class LoginPresenterImpl: LoginPresenter {
    private let view: LoginView
    private let authService: AuthService
    private let outputHandler: Handler<LoginScreenOutput>
    private var showError: VoidHandler?

    init(
        view: LoginView,
        outputHandler: @escaping Handler<LoginScreenOutput>,
        authService: AuthService,
        showing error: Error? = nil
    ) {
        self.view = view
        self.outputHandler = outputHandler
        self.authService = authService

        guard let error else { return }
        self.showError = { [view] in view.showErrorMessage(message: error.localizedDescription) }
    }

    func viewReady() {
        showError?()
        showError = nil
    }

    func login(token: String, isSandbox: Bool, rememberMe: Bool) {
        guard authService.isValidToken(text: token) else {
            view.highlightInvalidToken()
            return
        }

        let authData = AuthData(token: token, server: isSandbox ? .sandbox : .prod)

        view.switchState(isLoading: true)

        authService.login(auth: authData, shouldSave: rememberMe) { [weak self] result in
            guard let self else { return }

            view.switchState(isLoading: false)
            switch result {
            case .failure(let error):
                view.showErrorMessage(message: error.localizedDescription)
            case .success(let accounts):
                outputHandler(.receivedAccounts(accounts))
            }
        }
    }

    func help() {
        let dialog = Dialog(
            title: C.HelpDialog.title,
            text: C.HelpDialog.text,
            actions: [
                Dialog.Action(
                    title: C.HelpDialog.goButtonTitle,
                    kind: .primary,
                    handler: { [view] in view.openURL(C.HelpDialog.url) }
                ),
                Dialog.Action(
                    title: C.HelpDialog.cancelButtonTitle,
                    kind: .cancel,
                    handler: {}
                ),
            ]
        )
        view.showHelpDialog(dialog)
    }
}

// MARK: - C.HelpDialog

private extension C {
    enum HelpDialog {
        static let title = String(localized: "LoginPresenter.helpDialog.title", defaultValue: "Токен Invest API")
        static let text = String(
            localized: "LoginPresenter.helpDialog.text",
            defaultValue: "Для получения токена необходимо перейти в личный кабинет Т-Инвестиций"
        )
        static let goButtonTitle = String(localized: "LoginPresenter.helpDialog.goButton.title", defaultValue: "Перейти")
        static let cancelButtonTitle = String(localized: "LoginPresenter.helpDialog.cancelButton.title", defaultValue: "Отмена")
        static let url = URL(string: "https://www.tbank.ru/invest/settings/api/")!
    }
}
