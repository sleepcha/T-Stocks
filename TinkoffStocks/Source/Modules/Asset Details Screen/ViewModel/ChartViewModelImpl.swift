//
//  ChartViewModelImpl.swift
//  T-Stocks
//
//  Created by sleepcha on 1/14/25.
//

import Foundation

// MARK: - ChartViewModelImpl

final class ChartViewModelImpl: ChartViewModel, ObservableObject {
    @Published var candles = [CandleStickModel]() {
        didSet { updateValues() }
    }

    @Published private(set) var axisIndices = [Int]()
    @Published private(set) var closePrice: Decimal = 0
    @Published private(set) var minX: Int = 0
    @Published private(set) var maxX: Int = 0
    @Published private(set) var minY: Decimal = 0
    @Published private(set) var maxY: Decimal = 0

    private func updateValues() {
        minX = 0
        maxX = candles.count
        minY = candles.map(\.low).min() ?? 0
        maxY = candles.map(\.high).max() ?? 0

        var indices: [Int] = []
        var lastIndex: Int = 0

        guard let lastCandle = candles.last else {
            closePrice = 0
            axisIndices = []
            return
        }

        let (minPeriod, calendarUnit) = lastCandle.interval.minTimePeriod
        let minCandleCount = 7

        for i in 1..<candles.count {
            let lastDate = candles[lastIndex].date
            let date = candles[i].date

            if lastDate.interval(to: date, measuredIn: calendarUnit) >= minPeriod || indices.isEmpty {
                if i - lastIndex > minCandleCount {
                    indices.append(i)
                    lastIndex = i
                }
            }
        }

        closePrice = lastCandle.close
        axisIndices = indices
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
