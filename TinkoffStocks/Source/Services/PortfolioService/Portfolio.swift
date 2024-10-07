//
//  Portfolio.swift
//  T-Stocks
//
//  Created by sleepcha on 7/27/24.
//

import Foundation

struct Portfolio {
    struct Position {
        let quantity: Decimal
        let currentPrice: Decimal
        let averagePrice: Decimal
        let closePrice: Decimal?
        let isBlocked: Bool
        let asset: Asset
    }

    let account: AccountData
    let totalAmount: Decimal
    let positions: [Position]
}
