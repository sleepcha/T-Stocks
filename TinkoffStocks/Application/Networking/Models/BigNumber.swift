//
//  BigNumber.swift
//  TinkoffStocks
//
//  Created by sleepcha on 12/6/22.
//

import Foundation

// MARK: - BigNumber

protocol BigNumber {
    var units: String { get }
    var nano: Int { get }
}

extension BigNumber {
    var asDecimal: Decimal? {
        guard let integer = Decimal(string: units) else { return nil }

        let power = 9
        let significand = Decimal(nano)
        let fractional = Decimal(sign: significand.sign, exponent: -power, significand: significand)

        return integer + fractional
    }
}

extension Quotation: BigNumber {}

extension MoneyValue: BigNumber {}

extension Decimal {
    private var integer: Decimal {
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

    var asInt: Int {
        Int(truncating: integer as NSNumber)
    }

    var asQuotation: Quotation {
        let power = 9
        let fractional = self - integer
        let nano = Decimal(sign: sign, exponent: exponent + power, significand: fractional.significand)

        return Quotation(units: "\(integer)", nano: nano.integer.asInt)
    }
}
