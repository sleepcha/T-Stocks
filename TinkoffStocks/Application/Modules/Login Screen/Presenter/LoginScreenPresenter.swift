//
//  LoginScreenPresenter.swift
//  T-Stocks
//
//  Created by sleepcha on 8/21/24.
//

import Foundation

protocol LoginScreenPresenter {
    func viewReady()
    func login(token: String, isSandbox: Bool, rememberMe: Bool)
    func help()
}
