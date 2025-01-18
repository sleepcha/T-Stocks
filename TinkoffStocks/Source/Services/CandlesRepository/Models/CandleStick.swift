//
//  CandleStick.swift
//  T-Stocks
//
//  Created by sleepcha on 1/15/25.
//

import Foundation

struct CandleStick {
    let open: Decimal
    let high: Decimal
    let low: Decimal
    let close: Decimal
    let volume: Decimal
    let date: Date
    let isComplete: Bool
}
