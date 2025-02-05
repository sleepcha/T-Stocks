//
//  PriceUnit.swift
//  T-Stocks
//
//  Created by sleepcha on 1/21/25.
//

import Foundation

// MARK: - PriceUnit

enum PriceUnit {
    static let rub: PriceUnit = .currency("RUB")

    case futurePoints
    case currency(String?)
    case none
}

extension Decimal {
    func asPrice(measuredIn unit: PriceUnit) -> String {
        switch unit {
        case .futurePoints:
            formatted(.number
                .precision(.fractionLength(0...2))
                .rounded(rule: .toNearestOrEven)
                .sign(strategy: .never)
            ) + " \(C.Strings.futureSuffix)"
        case .currency(let isoCode?) where Locale.commonISOCurrencyCodes.contains(isoCode):
            formatted(.currency(code: isoCode)
                .precision(.fractionLength(0...2))
                .rounded(rule: .toNearestOrEven)
                .sign(strategy: .never)
            )
        default:
            formatted(.number
                .precision(.fractionLength(0...2))
                .rounded(rule: .toNearestOrEven)
                .sign(strategy: .never)
            )
        }
    }
}
