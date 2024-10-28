//
//  Date+Extensions.swift
//  T-Stocks
//
//  Created by sleepcha on 10/28/24.
//

import Foundation

extension Date {
    var morning: Date { Calendar.msk.date(bySettingHour: 7, minute: 0, second: 0, of: self)! }

    var nextWeekday: Date {
        var date = self

        repeat {
            date = date.adding(1, .day)
        } while Calendar.msk.isDateInWeekend(date)

        return date
    }

    var nextWeekdayMorning: Date {
        if self > morning { nextWeekday.morning } else { morning }
    }
}

extension Calendar {
    static let msk: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "MSK")!
        return calendar
    }()
}
