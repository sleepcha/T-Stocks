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

    enum TypeData {
        case share, etf, option, structuredProduct, other
        case currency(CurrencyData)
        case bond(BondData)
        case future(FutureData)
    }

    enum CurrencyType {
        case rub, cny, usd, eur, hkd, custom(String)

        init(isoCode: String) {
            self = switch isoCode.uppercased() {
            case "RUB": .rub
            case "CNY": .cny
            case "USD": .usd
            case "EUR": .eur
            case "HKD": .hkd
            default: .custom(isoCode)
            }
        }

        var isoCode: String? {
            switch self {
            case .rub: "RUB"
            case .cny: "CNY"
            case .usd: "USD"
            case .eur: "EUR"
            case .hkd: "HKD"
            case .custom(let code): code
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
    let typeData: TypeData

    var isRuble: Bool { id == C.ID.rubleAsset }
}

// MARK: - Helpers

extension Asset {
    var assetID: AssetID {
        let type: AssetID.AssetType = switch typeData {
        case .share: .share
        case .etf: .etf
        case .option: .option
        case .currency: .currency
        case .bond: .bond
        case .future: .future
        case .structuredProduct, .other: .other
        }

        return AssetID(id: id, assetType: type)
    }
}
