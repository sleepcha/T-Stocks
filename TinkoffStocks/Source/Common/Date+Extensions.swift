//
//  Date+Extensions.swift
//  T-Stocks
//
//  Created by sleepcha on 10/28/24.
//

import Foundation

extension Date {
    var secondToMidnight: Date { Calendar.msk.date(bySettingHour: 23, minute: 59, second: 59, of: self)! }
    var nextWeekdayMorning: Date {
        self > morning ? nextWeekday.morning : morning
    }

    private var morning: Date { Calendar.msk.date(bySettingHour: 7, minute: 0, second: 0, of: self)! }
    private var nextWeekday: Date {
        var date = self

        repeat {
            date = date.adding(1, .day)
        } while Calendar.msk.isDateInWeekend(date)

        return date
    }

    func adding(_ value: Int, _ component: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }
    
    func component(_ unit: Calendar.Component) -> Int {
        Calendar.current.component(unit, from: self)
    }

    func interval(to date: Date, measuredIn component: Calendar.Component) -> Int {
        let components = Calendar.current.dateComponents([component], from: self, to: date)
        return switch component {
        case .year: components.year!
        case .month: components.month!
        case .day: components.day!
        case .hour: components.hour!
        case .minute: components.minute!
        case .second: components.second!
        case .nanosecond: components.nanosecond!
        default: 0
        }
    }
}

extension Calendar {
    static let msk: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "MSK")!
        return calendar
    }()
}
