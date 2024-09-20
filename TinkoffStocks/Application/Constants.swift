//
//  Constants.swift
//  T-Stocks
//
//  Created by sleepcha on 8/13/24.
//

import Foundation

/// A global namespace for constants.
public enum C {
    public enum Keys {
        static let authTokenKeychain = "authToken"
    }

    public enum ID {
        static let keychainService = "com.sleepcha.T-Stocks"
        static let loggerSubsystem = "com.sleepcha.T-Stocks"
        static let appNameHeader = "sleepcha.T-Stocks"
        static let rubleAsset = "a92e2e25-a698-45cc-a781-167cf465257c"
    }

    public enum Defaults {
        static let retryCount = 2
        static let rateLimitReset: TimeInterval = 60
    }

    public enum UI {
        static let standardSpacing: CGFloat = 16
    }
}
