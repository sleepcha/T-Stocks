//
//  PortfolioData.swift
//  T-Stocks
//
//  Created by sleepcha on 8/18/24.
//

import Foundation

struct PortfolioData {
    struct Item {
        enum Kind: String {
            case share
            case bond
            case etf
            case futures
            case option
            case sp
            case currency
            case other
        }

        let id: String
        let kind: Kind
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
