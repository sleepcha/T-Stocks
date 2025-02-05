//
//  GainPeriod.swift
//  T-Stocks
//
//  Created by sleepcha on 10/6/24.
//

enum GainPeriod {
    case sinceLastClose, sincePurchase

    var title: String {
        switch self {
        case .sinceLastClose: String(localized: "AccountCell.sinceLastCloseTitle", defaultValue: "за сегодня")
        case .sincePurchase: String(localized: "AccountCell.sincePurchaseTitle", defaultValue: "за всё время")
        }
    }

    mutating func toggle() {
        self = switch self {
        case .sinceLastClose: .sincePurchase
        case .sincePurchase: .sinceLastClose
        }
    }
}
