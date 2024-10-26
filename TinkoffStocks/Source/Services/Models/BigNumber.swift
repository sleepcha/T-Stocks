//
//  BigNumber.swift
//  TinkoffStocks
//
//  Created by sleepcha on 12/6/22.
//

import Foundation

// MARK: - BigNumber

/// https://russianinvestments.github.io/investAPI/faq_custom_types/#moneyvalue
protocol BigNumber {
    var units: String { get }
    var nano: Int { get }
}

extension BigNumber {
    var asDecimal: Decimal? {
        guard let integer = Decimal(string: units) else { return nil }

        let significand = Decimal(nano)
        let fractional = Decimal(sign: significand.sign, exponent: -C.nanoLength, significand: significand)

        return integer + fractional
    }
}

extension Quotation: BigNumber {}

extension MoneyValue: BigNumber {}

extension Decimal {
    private var roundedToInteger: Decimal {
        let handler = NSDecimalNumberHandler(
            roundingMode: sign == .plus ? .down : .up,
            scale: 0,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        return (self as NSDecimalNumber).rounding(accordingToBehavior: handler) as Decimal
    }

    /// Rounding is necessary since the bug is still reproducible:
    /// https://github.com/swiftlang/swift-corelibs-foundation/issues/4315
    var asInt: Int {
        (roundedToInteger as NSDecimalNumber).intValue
    }

    var asQuotation: Quotation {
        let fractional = self - roundedToInteger
        let nano = Decimal(sign: sign, exponent: exponent + C.nanoLength, significand: fractional.significand)

        return Quotation(units: "\(roundedToInteger)", nano: nano.asInt)
    }

    func asMoney(_ currency: String) -> MoneyValue {
        let q = asQuotation
        return MoneyValue(currency: currency, units: q.units, nano: q.nano)
    }
}

// MARK: - Constants

private extension C {
    static let nanoLength = 9
}
