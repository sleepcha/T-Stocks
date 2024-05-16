//
//  InstrumentType+Extension.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/16/24.
//

import Foundation

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
        case .currency: 0
        case .share: 1
        case .etf: 2
        case .option: 3
        case .futures: 4
        case .bond: 5
        case .sp: 6
        case .clearingCertificate: 7
        case .index: 8
        case .commodity: 9
        default: 10
        }
    }
}
