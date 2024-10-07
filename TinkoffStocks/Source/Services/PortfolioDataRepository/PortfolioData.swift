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
            case share, etf, option, sp, currency, bond, futures, other
        }

        let id: String
        let kind: Kind
        let quantity: Decimal
        let currentPrice: Decimal
        let averagePrice: Decimal
        let isBlocked: Bool
    }

    let id: String
    let totalAmount: Decimal
    let items: [Item]
}
