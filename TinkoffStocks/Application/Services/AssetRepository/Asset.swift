//
//  Asset.swift
//  T-Stocks
//
//  Created by sleepcha on 7/16/24.
//

struct Asset {
    enum Kind {
        case share
        case bond
        case etf
        case futures
        case option
        case structuredProduct
        case currency
        case other
    }

    enum CurrencyType: String {
        case rub
        case usd
        case eur
        case hkd
        case other
    }

    let id: String
    let name: String
    let ticker: String
    let logoName: String
    let currency: CurrencyType
    let lot: Int
    let isShortAvailable: Bool
    let kind: Kind
}
