//
//  AssetPositionModel.swift
//  T-Stocks
//
//  Created by sleepcha on 1/13/25.
//

import Foundation

struct AssetPositionModel: Identifiable {
    var id: UUID = UUID()
    var accountName: String
    var quantity: String
    var priceChange: String
    var value: String
    var gain: String
    var gainState: GainState
}