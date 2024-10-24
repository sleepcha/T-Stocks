//
//  PortfolioItemFormatter.swift
//  T-Stocks
//
//  Created by sleepcha on 10/6/24.
//

import Foundation

// MARK: - PortfolioItemFormatter

enum PortfolioItemFormatter {
    static func mapToPortfolioItemCellModel(item: Portfolio.Item, gainPeriod: GainPeriod) -> PortfolioItemCellModel {
        let asset = item.asset
        let calc = PortfolioItemCalculator(item: item, gainPeriod: gainPeriod)
        let value = calc.value.asCurrency(asset.currency.isoCode ?? "")

        guard !asset.isRuble else {
            return PortfolioItemCellModel(
                id: asset.id,
                ticker: asset.ticker,
                name: asset.name,
                quantity: "",
                value: value,
                gain: NSAttributedString(),
                priceChange: "",
                backgroundColor: asset.brand.bgColor,
                textColor: asset.brand.textColor
            )
        }

        let gainAmountString = abs(calc.gain).asCurrency(asset.currency.isoCode ?? "")
        let gainPercentString = abs(calc.gainPercent).asPercent
        let gainState = GainState(value: calc.gain)
        let gainString = NSAttributedString(
            string: "\(gainState.sign)\(gainAmountString) · \(gainPercentString)",
            attributes: [.foregroundColor: gainState.textColor]
        )

        let fractionLength: Int = asset.minPriceIncrement.fractionDigits
        let initialPrice = calc.initialPrice.formatted(.number.precision(.fractionLength(0...fractionLength)))
        let marketPrice = calc.marketPrice.formatted(.number.precision(.fractionLength(0...fractionLength)))

        var quantity = switch asset.kind {
        case .currency(let currencyData) where currencyData.isMetal:
            item.quantity.asMetal
        case .currency(let currencyData):
            item.quantity.asCurrency(currencyData.isoCode)
        default:
            item.quantity.asAmount
        }
        if item.isBlocked { quantity += "🔒" }

        return PortfolioItemCellModel(
            id: asset.id,
            ticker: asset.ticker,
            name: asset.name,
            quantity: quantity,
            value: value,
            gain: gainString,
            priceChange: "\(initialPrice) → \(marketPrice)",
            backgroundColor: asset.brand.bgColor,
            textColor: asset.brand.textColor
        )
    }
}

// MARK: - Helpers

private extension Decimal {
    static let precision: Decimal.FormatStyle.Configuration.Precision = .fractionLength(0...2)

    var fractionDigits: Int { -exponent }

    var asAmount: String {
        let amountSuffix = String(localized: "MoneyFormatter.amountSuffix", defaultValue: "шт")
        return formatted(.number.precision(Self.precision)) + " \(amountSuffix)"
    }

    var asPercent: String {
        formatted(.percent.precision(Self.precision))
    }

    var asMetal: String {
        let weightSuffix = String(localized: "MoneyFormatter.metalWeightSuffix", defaultValue: "г")
        return formatted(.number.precision(Self.precision)) + " \(weightSuffix)"
    }

    func asCurrency(_ isoCode: String) -> String {
        formatted(.currency(code: isoCode).precision(Self.precision))
    }
}
