//
//  BondData.swift
//  T-Stocks
//
//  Created by sleepcha on 7/28/24.
//

import Foundation

struct BondData {
    let couponsPerYear: Int
    let maturityDate: Date?
    let faceValue: Decimal
    let accruedInterest: Decimal
    let isPerpetual: Bool
    let isFloater: Bool
    let isAmortized: Bool
}
