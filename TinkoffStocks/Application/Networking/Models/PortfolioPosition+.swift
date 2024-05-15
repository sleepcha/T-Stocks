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

extension InstrumentType {
    var name: String {
        switch self {
        case .bond: "Облигации"
        case .share: "Акции"
        case .currency: "Валюта и металлы"
        case .etf: "Фонды"
        case .futures: "Фьючерсы"
        case .sp: "Структурные ноты"
        case .option: "Опционы"
        case .clearingCertificate: "КСУ"
        case .index: "Индексы"
        case .commodity: "Товары"
        case .unspecified: "Другое"
        }
    }

    var order: Int {
        switch self {
        case .bond: 5
        case .share: 1
        case .currency: 0
        case .etf: 2
        case .futures: 4
        case .sp: 6
        case .option: 3
        case .clearingCertificate: 7
        case .index: 8
        case .commodity: 9
        default: 10
        }
    }
}
