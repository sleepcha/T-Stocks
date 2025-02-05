//
//  PriceChange.swift
//  T-Stocks
//
//  Created by sleepcha on 9/28/24.
//

import Foundation

struct PriceChange {
    enum Outcome {
        case profit
        case loss
        case neutral
    }

    static let zero: PriceChange = .init(from: 0, to: 0)

    var outcome: Outcome {
        switch (quantity * diff).sign {
        case .plus: diff.isZero ? .neutral : .profit
        case .minus: .loss
        }
    }

    var formattedProfit: String {
        let profit = (quantity * diff).asPrice(measuredIn: unit)
        let percentValue = initialPrice.isZero ? 0 : currentPrice / initialPrice - 1
        let profitPercent = percentValue.formatted(.percent
            .sign(strategy: .never)
            .precision(.fractionLength(0...2))
            .rounded(rule: .toNearestOrEven)
        )

        return "\(sign)\(profit) · \(profitPercent)"
    }

    var formatted: String {
        let initialPrice = initialPrice.formatted(.number.precision(.fractionLength(0...fractionLength)))
        let currentPrice = currentPrice.formatted(.number.precision(.fractionLength(0...fractionLength)))

        return "\(initialPrice) → \(currentPrice)"
    }

    private let initialPrice: Decimal
    private let currentPrice: Decimal
    private let fractionLength: Int
    private let quantity: Decimal
    private let unit: PriceUnit

    private var diff: Decimal { currentPrice - initialPrice }
    private var sign: String {
        switch outcome {
        case .profit: "↑"
        case .loss: "↓"
        case .neutral: ""
        }
    }

    init(
        from initialPrice: Decimal,
        to currentPrice: Decimal,
        fractionLength: Int = 2,
        quantity: Decimal = 1,
        unit: PriceUnit = .none
    ) {
        self.initialPrice = initialPrice
        self.currentPrice = currentPrice
        self.fractionLength = fractionLength
        self.quantity = quantity
        self.unit = unit
    }
}
