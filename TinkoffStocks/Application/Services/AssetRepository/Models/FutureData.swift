//
//  FutureData.swift
//  T-Stocks
//
//  Created by sleepcha on 7/28/24.
//

import Foundation

struct FutureData {
    let priceIncrementValue: Decimal
    let underlyingAssetSize: Decimal
    let expirationDate: Date
    let initialMarginOnBuy: Decimal
    let initialMarginOnSell: Decimal
}
