//
//  LoginView.swift
//  T-Stocks
//
//  Created by sleepcha on 8/14/24.
//

import Foundation

protocol LoginView {
    func switchState(isLoading: Bool)
    func highlightInvalidToken()
    func showErrorMessage(message: String)
    func showHelpDialog(_ dialog: Dialog)
    func openURL(_ url: URL)
}
