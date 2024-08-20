//
//  URL + ExpressibleByStringLiteral.swift
//  T-Stocks
//
//  Created by sleepcha on 8/8/24.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    /// A convenience for using string literals as URLs
    public init(stringLiteral value: StaticString) {
        self.init(string: "\(value)")!
    }
}
