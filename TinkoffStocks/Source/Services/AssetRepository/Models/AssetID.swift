//
//  AssetID.swift
//  T-Stocks
//
//  Created by sleepcha on 9/19/24.
//

import Foundation

struct AssetID: IdentifiableHashable {
    enum AssetType {
        case share
        case bond
        case etf
        case future
        case option
        case currency
        case other
    }

    let id: String
    let assetType: AssetType
}
