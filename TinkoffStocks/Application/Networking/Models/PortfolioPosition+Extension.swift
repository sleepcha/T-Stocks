//
//  PortfolioPosition+.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/3/24.
//

import Foundation

extension PortfolioPosition {
    var instrumentKind: InstrumentType {
        switch instrumentType {
        case "bond": .bond
        case "share": .share
        case "currency": .currency
        case "etf": .etf
        case "futures": .futures
        case "sp": .sp
        case "option": .option
        case "clearingcertificate": .clearingCertificate
        default: .unspecified
        }
    }

    var average: Decimal {
        averagePositionPrice?.asDecimal ?? 0
    }

    var gain: Decimal {
        currentPrice?.asDecimal ?? 0 - average
    }

    var change: Decimal {
        average == 0 ? 0 : gain / average
    }
}
