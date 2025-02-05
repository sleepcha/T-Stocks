//
//  PortfolioFormatters.swift
//  T-Stocks
//
//  Created by sleepcha on 10/6/24.
//

import UIKit

// MARK: - PortfolioFormatters

enum PortfolioFormatters {
    static func mapToPortfolioSummary(portfolio: Portfolio, gainPeriod: GainPeriod) -> PortfolioSummary {
        let total = portfolio.totalAmount
        let gain = portfolio.items.values
            .filter { !$0.isBlocked }
            .map { $0.gain(for: gainPeriod) }
            .reduce(0, +)

        return (
            total: total.asPrice(measuredIn: .rub),
            gain: PriceChange(from: total - gain, to: total, unit: .rub).attributedProfit
        )
    }

    static func mapToAccountCellModel(portfolio: Portfolio, gainPeriod: GainPeriod) -> AccountCellModel {
        let summary = mapToPortfolioSummary(portfolio: portfolio, gainPeriod: gainPeriod)

        return AccountCellModel(
            id: portfolio.account.id,
            name: portfolio.account.name,
            value: summary.total,
            gain: summary.gain,
            gainPeriodButtonTitle: gainPeriod.title
        )
    }

    static func mapToPortfolioItemCellModel(item: Portfolio.Item, gainPeriod: GainPeriod) -> PortfolioItemCellModel {
        let asset = item.asset
        let value = item.value(for: gainPeriod).asPrice(measuredIn: .currency(asset.currency.isoCode))

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
        let priceChange = item.priceChange(for: gainPeriod)

        return PortfolioItemCellModel(
            id: asset.id,
            ticker: asset.ticker,
            name: asset.name,
            quantity: quantityString,
            value: value,
            gain: priceChange.attributedProfit,
            priceChange: priceChange.formatted,
            backgroundColor: asset.brand.bgColor,
            textColor: asset.brand.textColor
        )
    }

    static func mapToAssetPositionModel(position: PortfolioData.OpenPosition, asset: Asset, accountName: String) -> AssetPositionModel {
        AssetPositionModel(
            accountName: accountName,
            quantity: formatQuantity(typeData: asset.typeData, quantity: position.quantity, isBlocked: position.isBlockedInstrument),
            value: position.value(asset: asset).asPrice(measuredIn: .currency(asset.currency.isoCode)),
            priceChange: position.priceChange(asset: asset)
        )
    }

    static func formatPrice(price: Decimal, asset: Asset) -> String {
        let iso = asset.currency.isoCode ?? ""
        let fractionLength = asset.fractionLength

        return switch asset.typeData {
        case .future:
            price.asNumber(fractionLength: fractionLength) + " \(C.Strings.futureSuffix)"
        case .bond(let bondData):
            (price * bondData.faceValue / 100).asCurrency(iso, fractionLength: fractionLength)
        default:
            price.asCurrency(iso, fractionLength: fractionLength)
        }
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
}

// MARK: - Helpers

private extension Decimal {
    var asAmount: String {
        asNumber() + " \(C.Strings.amountSuffix)"
    }

    var asMetal: String {
        asNumber() + " \(C.Strings.weightSuffix)"
    }

    func asNumber(fractionLength: Int = 2) -> String {
        formatted(.number
            .precision(.fractionLength(0...fractionLength))
            .rounded(rule: .toNearestOrEven)
        )
    }

    func asCurrency(_ iso: String, fractionLength: Int = 2) -> String {
        formatted(.currency(code: iso)
            .precision(.fractionLength(0...fractionLength))
            .rounded(rule: .toNearestOrEven)
        )
    }
}

private extension Portfolio.Item {
    func gain(for gainPeriod: GainPeriod) -> Decimal {
        quantity * (currentPrice - initialPrice(for: gainPeriod)) * asset.pointValue
    }

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

    func value(for gainPeriod: GainPeriod) -> Decimal {
        quantity * (currentPrice + asset.accruedInterest) * asset.pointValue
    }

    func priceChange(for gainPeriod: GainPeriod) -> PriceChange {
        PriceChange(
            from: initialPrice(for: gainPeriod),
            to: currentPrice,
            fractionLength: asset.fractionLength,
            quantity: quantity * asset.pointValue,
            unit: .currency(asset.currency.isoCode)
        )
    }
}

private extension PortfolioData.OpenPosition {
    func value(asset: Asset) -> Decimal {
        quantity * (currentPrice + asset.accruedInterest) * asset.pointValue
    }

    func priceChange(asset: Asset) -> PriceChange {
        PriceChange(
            from: averagePrice,
            to: currentPrice,
            fractionLength: asset.fractionLength,
            quantity: quantity * asset.pointValue,
            unit: .currency(asset.currency.isoCode)
        )
    }
}

private extension PriceChange {
    var textColor: UIColor {
        switch outcome {
        case .profit: .profit
        case .loss: .loss
        case .neutral: .neutral
        }
    }

    var attributedProfit: NSAttributedString {
        NSAttributedString(string: formattedProfit, attributes: [.foregroundColor: textColor])
    }
}
