//
//  LoginPresenter.swift
//  T-Stocks
//
//  Created by sleepcha on 8/21/24.
//

protocol LoginPresenter: AnyObject {
    func viewReady()
    func login(token: String, isSandbox: Bool, rememberMe: Bool)
    func help()
}
