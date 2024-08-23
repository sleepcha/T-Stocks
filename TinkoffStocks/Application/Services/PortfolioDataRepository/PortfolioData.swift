//
//  PortfolioData.swift
//  T-Stocks
//
//  Created by sleepcha on 8/18/24.
//

import Foundation

struct PortfolioData {
    struct Item {
        let id: String
        let quantity: Decimal
        let currentPrice: Decimal
        let averagePrice: Decimal
        let accruedInterest: Decimal?
        let gain: Decimal
    }

    let id: String
    let gainPercent: Decimal
    let totalAmount: Decimal
    let items: [Item]
}
