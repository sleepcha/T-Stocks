//
//  PortfolioFormatter.swift
//  T-Stocks
//
//  Created by sleepcha on 10/8/24.
//

import Foundation

enum PortfolioFormatter {
    static func mapToPortfolioSummary(portfolio: Portfolio, gainPeriod: GainPeriod) -> PortfolioSummary {
        let precision: Decimal.FormatStyle.Configuration.Precision = .fractionLength(0...2)
        let value = portfolio.totalAmount
        let gain = portfolio.items.values
            .map { PortfolioItemCalculator(item: $0, gainPeriod: gainPeriod).gain }
            .reduce(0, +)
        let gainState = GainState(value: gain)

        let initialValue = value - gain
        let gainPercent = initialValue.isZero ? 0 : gain / initialValue

        let valueString = value.formatted(.number.precision(precision))
        let gainString: NSAttributedString = {
            let gain = gain.formatted(.number.precision(precision).sign(strategy: .never))
            let gainPercent = gainPercent.formatted(.percent.precision(precision).sign(strategy: .never))

            return NSAttributedString(
                string: "\(gainState.sign)\(gain) · \(gainPercent)",
                attributes: [.foregroundColor: gainState.textColor]
            )
        }()

        return (valueString, gainString)
    }

    static func mapToAccountCellModel(portfolio: Portfolio, gainPeriod: GainPeriod) -> AccountCellModel {
        let formatted = mapToPortfolioSummary(portfolio: portfolio, gainPeriod: gainPeriod)

        return AccountCellModel(
            id: portfolio.account.id,
            name: portfolio.account.name,
            value: formatted.total,
            gain: formatted.gain,
            gainPeriodButtonTitle: gainPeriod.title
        )
    }
}


extension PortfolioItemCalculator {
        init(item: Portfolio.Item, gainPeriod: GainPeriod) {
            self.marketPrice = item.currentPrice
            self.initialPrice = item.initialPrice(for: gainPeriod)
            self.quantity = item.quantity
            self.pointValue = item.asset.pointValue
            self.accruedInterest = item.asset.accruedInterest
        }
}
