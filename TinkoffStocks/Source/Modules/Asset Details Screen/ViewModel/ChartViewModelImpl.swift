//
//  ChartViewModelImpl.swift
//  T-Stocks
//
//  Created by sleepcha on 1/14/25.
//

import Foundation

// MARK: - ChartViewModelImpl

final class ChartViewModelImpl: ChartViewModel, ObservableObject {
    @Published private(set) var candles = [CandleStickModel]()
    private(set) var axisIndices = [Int]()
    private(set) var closePrice: Decimal = 0
    private(set) var rangeX: ClosedRange<Int> = 0...0
    private(set) var rangeY: ClosedRange<Decimal> = 0...0

    func update(with newCandles: [CandleStickModel]) {
        rangeX = 0...newCandles.count
        let minY = newCandles.map(\.low).min() ?? 0
        let maxY = newCandles.map(\.high).max() ?? 0
        rangeY = minY...maxY

        var indices: [Int] = []
        var lastIndex: Int = 0

        guard let lastCandle = newCandles.last else {
            closePrice = 0
            axisIndices = []
            return
        }

        let (minPeriod, calendarUnit) = lastCandle.interval.minTimePeriod
        let minCandleCount = 7

        for i in 1..<newCandles.count {
            let lastDate = newCandles[lastIndex].date
            let date = newCandles[i].date

            if lastDate.interval(to: date, measuredIn: calendarUnit) >= minPeriod || indices.isEmpty {
                if i - lastIndex > minCandleCount {
                    indices.append(i)
                    lastIndex = i
                }
            }
        }

        closePrice = lastCandle.close
        axisIndices = indices
        candles = newCandles
    }
}

// MARK: - Helpers

private extension CandleStickInterval {
    var minTimePeriod: (Int, Calendar.Component) {
        switch self {
        case .min5: (1, .hour)
        case .min15: (2, .hour)
        case .min30: (1, .day)
        case .hour1: (1, .day)
        case .hour4: (2, .day)
        case .day: (1, .month)
        case .week: (2, .month)
        case .month: (1, .year)
        }
    }
}
