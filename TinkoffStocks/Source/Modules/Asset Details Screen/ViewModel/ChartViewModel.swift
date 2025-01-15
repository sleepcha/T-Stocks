//
//  ChartViewModel.swift
//  T-Stocks
//
//  Created by sleepcha on 1/12/25.
//

import Foundation

protocol ChartViewModel: ObservableObject {
    var candles: [CandleStickModel] { get set }
    var axisIndices: [Int] { get }
    var closePrice: Decimal { get }
    var minX: Int { get }
    var maxX: Int { get }
    var minY: Decimal { get }
    var maxY: Decimal { get }
}
