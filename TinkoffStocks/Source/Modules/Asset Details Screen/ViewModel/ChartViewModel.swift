//
//  ChartViewModel.swift
//  T-Stocks
//
//  Created by sleepcha on 1/12/25.
//

import Foundation

protocol ChartViewModel: ObservableObject {
    var candles: [CandleStickModel] { get }
    var axisIndices: [Int] { get }
    var closePrice: Decimal { get }
    var rangeX: ClosedRange<Int> { get }
    var rangeY: ClosedRange<Decimal> { get }
    
    func update(with newCandles: [CandleStickModel])
}
