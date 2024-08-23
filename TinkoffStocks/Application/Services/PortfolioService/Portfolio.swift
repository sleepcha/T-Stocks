//
//  Portfolio.swift
//  T-Stocks
//
//  Created by sleepcha on 7/27/24.
//

import Foundation

struct Portfolio {
    struct Position {
        let id: String
        let quantity: Decimal
        let currentPrice: Decimal
        let averagePrice: Decimal
        let closePrice: Decimal?
        let accruedInterest: Decimal?
        let gain: Decimal

        let name: String
        let ticker: String
        let logoName: String
        let currency: Asset.CurrencyType
        let assetKind: Asset.Kind
    }

    let account: AccountData
    let gainPercent: Decimal
    let totalAmount: Decimal
    let positions: [Position]
}
