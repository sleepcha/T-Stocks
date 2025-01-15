//
//  CandleStickModel.swift
//  T-Stocks
//
//  Created by sleepcha on 1/12/25.
//

import Foundation

struct CandleStickModel {
    let interval: CandleStickInterval
    let open: Decimal
    let high: Decimal
    let low: Decimal
    let close: Decimal
    let date: Date

    var gainState: GainState {
        if open == close { .neutral }
        else { open > close ? .loss : .profit }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.calendar = .current
        if interval == .min5 || interval == .min15 {
            // enforce 24h format
            formatter.locale = Locale(identifier: "en_US_POSIX")
        }
        formatter.dateFormat = switch interval {
        case .min5, .min15: "HH:mm"
        case .min30, .hour1, .hour4: "dd MMM"
        case .day, .week: "LLL"
        case .month: "yyyy"
        }
        return formatter.string(from: date)
    }

    init(from candle: CandleStick, interval: CandleStickInterval) {
        self.open = candle.open
        self.high = candle.high
        self.low = candle.low
        self.close = candle.close
        self.date = candle.date
        self.interval = interval
    }
}
