//
//  PortfolioItemCalculator.swift
//  T-Stocks
//
//  Created by sleepcha on 10/5/24.
//

import Foundation

// MARK: - PortfolioItemCalculator

struct PortfolioItemCalculator {
    let initialPrice: Decimal
    let marketPrice: Decimal

    private let quantity: Decimal
    private let pointValue: Decimal
    private let accruedInterest: Decimal

    var value: Decimal {
        quantity * (marketPrice + accruedInterest) * pointValue
    }

    var gain: Decimal {
        guard !initialPrice.isZero else { return 0 }

        return quantity * (marketPrice - initialPrice) * pointValue
    }

    var gainPercent: Decimal {
        guard !initialPrice.isZero else { return 0 }

        return marketPrice / initialPrice - 1
    }

    init(item: Portfolio.Item, gainPeriod: GainPeriod) {
        self.marketPrice = item.currentPrice
        self.initialPrice = item.initialPrice(for: gainPeriod)
        self.quantity = item.quantity
        self.pointValue = item.asset.pointValue

        self.accruedInterest = switch item.asset.typeData {
        case .bond(let bondData): bondData.accruedInterest
        default: 0
        }
    }
}

// MARK: - Helpers

extension Asset {
    var pointValue: Decimal {
        guard case .future(let futureData) = typeData else { return 1 }
        guard !minPriceIncrement.isZero else { return 0 }

        return futureData.priceIncrementValue / minPriceIncrement
    }
}

extension Portfolio.Item {
    func initialPrice(for gainPeriod: GainPeriod) -> Decimal {
        switch gainPeriod {
        case .sincePurchase:
            return averagePrice
        case .sinceLastClose:
            // no data - no gain (return current price)
            guard var closePrice else { return currentPrice }

            // bonds' closePrice is measured in faceValue percent
            if case .bond(let bondData) = asset.typeData { closePrice *= bondData.faceValue / 100 }
            return closePrice
        }
    }
}
