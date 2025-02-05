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
        static let metalExchange = "FX_MTL"
    }

    public enum Defaults {
        static let retryCount = 2
        static let rateLimitReset: TimeInterval = 60
    }

    public enum UI {
        static let spacing: CGFloat = 8
        static let doubleSpacing: CGFloat = 16
    }
    
    public enum Strings {
        static let futureSuffix = String(localized: "MoneyFormatter.futuresSuffix", defaultValue: "пт.")
        static let amountSuffix = String(localized: "MoneyFormatter.amountSuffix", defaultValue: "шт")
        static let weightSuffix = String(localized: "MoneyFormatter.metalWeightSuffix", defaultValue: "г")
    }
}
