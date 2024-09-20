//
//  Asset.swift
//  T-Stocks
//
//  Created by sleepcha on 7/16/24.
//

import Foundation

// MARK: - Asset

struct Asset {
    struct Brand {
        let logoName: String
        let bgColor: String
        let textColor: String
    }

    enum Kind {
        case share, etf, option, structuredProduct, other
        case currency(CurrencyData)
        case bond(BondData)
        case future(FutureData)
    }

    enum CurrencyType {
        case rub, cny, usd, eur, hkd, other

        init(isoCode: String) {
            self = switch isoCode.uppercased() {
            case "RUB": .rub
            case "CNY": .cny
            case "USD": .usd
            case "EUR": .eur
            case "HKD": .hkd
            default: .other
            }
        }

        var isoCode: String? {
            switch self {
            case .rub: "RUB"
            case .cny: "CNY"
            case .usd: "USD"
            case .eur: "EUR"
            case .hkd: "HKD"
            case .other: nil
            }
        }
    }

    let id: String
    let name: String
    let ticker: String
    let brand: Brand
    let currency: CurrencyType
    let lot: Int
    let minPriceIncrement: Decimal
    let isShortAvailable: Bool
    let kind: Kind
}

extension Asset.Kind: Equatable, Hashable {
    static func == (lhs: Asset.Kind, rhs: Asset.Kind) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    private var id: Int {
        switch self {
        case .share: 0
        case .etf: 1
        case .option: 2
        case .structuredProduct: 3
        case .currency: 4
        case .other: 5
        case .bond: 6
        case .future: 7
        }
    }
}
