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

        let quantityString = formatQuantity(typeData: asset.typeData, quantity: item.quantity, isBlocked: item.isBlocked)
        let gainString = formatGainWithColor(gain: calc.gain, gainPercent: calc.gainPercent, isoCode: asset.currency.isoCode ?? "")

        let priceChangeString = formatPriceChange(
            initialPrice: calc.initialPrice,
            marketPrice: calc.marketPrice,
            minPriceIncrement: asset.minPriceIncrement
        )

        return PortfolioItemCellModel(
            id: asset.id,
            ticker: asset.ticker,
            name: asset.name,
            quantity: quantityString,
            value: value,
            gain: gainString,
            priceChange: priceChangeString,
            backgroundColor: asset.brand.bgColor,
            textColor: asset.brand.textColor
        )
    }

    static func mapToAssetPositionModel(position: PortfolioData.OpenPosition, asset: Asset, accountName: String) -> AssetPositionModel {
        let calc = PortfolioItemCalculator(position: position, asset: asset)
        let valueString = calc.value.asCurrency(asset.currency.isoCode ?? "")
        let gainString = formatGain(gain: calc.gain, gainPercent: calc.gainPercent, isoCode: asset.currency.isoCode ?? "")
        let priceChangeString = formatPriceChange(
            initialPrice: calc.initialPrice,
            marketPrice: calc.marketPrice,
            minPriceIncrement: asset.minPriceIncrement
        )

        return AssetPositionModel(
            accountName: accountName,
            quantity: Self.formatQuantity(typeData: asset.typeData, quantity: position.quantity, isBlocked: position.isBlockedInstrument),
            priceChange: priceChangeString,
            value: valueString,
            gain: gainString,
            gainState: GainState(value: calc.gain)
        )
    }

    static func formatCandleStickModel(candle: CandleStickModel, asset: Asset) -> (price: String, gain: String) {
        let calc = PortfolioItemCalculator(candle: candle, asset: asset)
        let value = formatPrice(price: candle.close, asset: asset)
        let gainString = formatGain(gain: calc.gain, gainPercent: calc.gainPercent, isoCode: asset.currency.isoCode ?? "")
        return (price: value, gain: gainString)
    }

    static func formatGain(gain: Decimal, gainPercent: Decimal, isoCode: String) -> String {
        let gainAmountString = abs(gain).asCurrency(isoCode)
        let gainPercentString = abs(gainPercent).asPercent
        return "\(GainState(value: gain).sign)\(gainAmountString) · \(gainPercentString)"
    }

    private static func formatPrice(price: Decimal, asset: Asset) -> String {
        let iso = asset.currency.isoCode ?? ""

        return switch asset.typeData {
        case .future:
            price.asFutures
        case .bond(let bondData):
            (price * bondData.faceValue / 100).formatted(.currency(code: iso))
        default:
            price.formatted(.currency(code: iso))
        }
    }

    private static func formatGainWithColor(gain: Decimal, gainPercent: Decimal, isoCode: String) -> NSAttributedString {
        NSAttributedString(
            string: formatGain(gain: gain, gainPercent: gainPercent, isoCode: isoCode),
            attributes: [.foregroundColor: GainState(value: gain).textColor]
        )
    }

    private static func formatQuantity(typeData: Asset.TypeData, quantity: Decimal, isBlocked: Bool) -> String {
        var quantity = switch typeData {
        case .currency(let currencyData) where currencyData.isMetal:
            quantity.asMetal
        case .currency(let currencyData):
            quantity.asCurrency(currencyData.isoCode)
        default:
            quantity.asAmount
        }
        if isBlocked { quantity += "🔒" }

        return quantity
    }

    private static func formatPriceChange(initialPrice: Decimal, marketPrice: Decimal, minPriceIncrement: Decimal) -> String {
        let fractionLength = minPriceIncrement.fractionDigits
        let initialPrice = initialPrice.formatted(fractionLength: fractionLength)
        let marketPrice = marketPrice.formatted(fractionLength: fractionLength)

        return "\(initialPrice) → \(marketPrice)"
    }
}

// MARK: - Helpers

private extension Decimal {
    var fractionDigits: Int { -exponent }

    var asAmount: String {
        let amountSuffix = String(localized: "MoneyFormatter.amountSuffix", defaultValue: "шт")
        return formatted(fractionLength: 2) + " \(amountSuffix)"
    }

    var asMetal: String {
        let weightSuffix = String(localized: "MoneyFormatter.metalWeightSuffix", defaultValue: "г")
        return formatted(fractionLength: 2) + " \(weightSuffix)"
    }

    var asFutures: String {
        let ptSuffix = String(localized: "MoneyFormatter.futuresSuffix", defaultValue: "пт.")
        return formatted(fractionLength: 2) + " \(ptSuffix)"
    }

    var asPercent: String {
        formatted(.percent.precision(.fractionLength(0...2)))
    }

    func asCurrency(_ isoCode: String) -> String {
        formatted(.currency(code: isoCode).precision(.fractionLength(0...2)))
    }

    func formatted(fractionLength: Int) -> String {
        formatted(.number.precision(.fractionLength(0...fractionLength)))
    }
}

private extension PortfolioItemCalculator {
    init(position: PortfolioData.OpenPosition, asset: Asset) {
        self.marketPrice = position.currentPrice
        self.initialPrice = position.averagePrice
        self.quantity = position.quantity
        self.pointValue = asset.pointValue
        self.accruedInterest = asset.accruedInterest
    }

    init(candle: CandleStickModel, asset: Asset) {
        self.marketPrice = candle.close
        self.initialPrice = candle.open
        self.quantity = 1
        self.pointValue = asset.pointValue
        self.accruedInterest = 0
    }
}
