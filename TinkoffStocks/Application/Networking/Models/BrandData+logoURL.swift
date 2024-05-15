//
//  BrandData+logoURL.swift
//  TinkoffStocks
//
//  Created by sleepcha on 2/9/24.
//

import Foundation

extension BrandData {
    var logoURL: URL? {
        let logoName = logoName.replacingOccurrences(of: ".png", with: "x160.png", options: .backwards)
        return URL(string: "https://invest-brands.cdn-tinkoff.ru/\(logoName)")
    }
}
