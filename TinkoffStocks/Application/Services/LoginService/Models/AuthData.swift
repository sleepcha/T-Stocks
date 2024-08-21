//
//  AuthData.swift
//  T-Stocks
//
//  Created by sleepcha on 7/30/24.
//

import Foundation

struct AuthData: Codable {
    enum ServerEnvironment: String, Codable {
        case prod
        case sandbox
    }

    let token: String
    let server: ServerEnvironment

    var isSandbox: Bool { server == .sandbox }
}
