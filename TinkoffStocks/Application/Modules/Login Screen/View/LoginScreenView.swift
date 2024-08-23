//
//  LoginScreenView.swift
//  T-Stocks
//
//  Created by sleepcha on 8/14/24.
//

import Foundation

protocol LoginScreenView {
    func switchState(isLoading: Bool)
    func indicateInvalidToken()
    func showErrorMessage(message: String)
    func showHelpDialog(_ dialog: Dialog)
    func openURL(_ url: URL)
}
