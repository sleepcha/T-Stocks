//
//  BigNumber.swift
//  TinkoffStocks
//
//  Created by sleepcha on 12/6/22.
//

import Foundation


protocol BigNumber {
    var units: String? { get }
    var nano: Int? { get }
}

extension BigNumber {
    var asDecimal: Decimal? {
        guard let units = units?.asInt, let nano else { return nil }
        
        let power = 9
        let integer = Decimal(units)
        let significand = Decimal(nano)
        let fractional = Decimal(sign: significand.sign, exponent: -power, significand: significand)

        return integer + fractional
    }
}

extension Quotation: BigNumber {}

extension MoneyValue: BigNumber {}

extension Decimal {
    var asDouble: Double {
        (self as NSNumber).doubleValue
    }
    
    var asInteger: Int {
        return Int(self.asDouble)
    }
    
    var asQuotation: Quotation {
        let integer = self.asInteger
        let fractional = self - Decimal(integer)
        let nano = Decimal(sign: self.sign, exponent: self.exponent + 9, significand: fractional.significand)
        
        return Quotation(units: String(integer), nano: nano.asInteger)
    }
}

extension String {
    var asInt: Int? { return Int(self) }
}
