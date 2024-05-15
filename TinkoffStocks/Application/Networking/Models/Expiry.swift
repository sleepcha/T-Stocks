//
//  Expiry.swift
//  TradeTerminal
//
//  Created by sleepcha on 4/12/23.
//

import Foundation

// MARK: - Expiry

enum Expiry {
    enum Period {
        case second(Int)
        case minute(Int)
        case hour(Int)
        case day(Int)
        case month(Int)

        func expiration(for date: Date) -> Date {
            switch self {
            case let .second(value): date.adding(value, .second)
            case let .minute(value): date.adding(value, .minute)
            case let .hour(value): date.adding(value, .hour)
            case let .day(value): date.adding(value, .day)
            case let .month(value): date.adding(value, .month)
            }
        }
    }

    case `for`(Period)
    case until(Date)
    case forever

    func isValid(creationDate: Date) -> Bool {
        let expirationDate = switch self {
        case let .for(period): period.expiration(for: creationDate)
        case let .until(deadline): deadline
        case .forever: Date.distantFuture
        }

        return Date.now < expirationDate
    }
}

extension Date {
    func adding(_ value: Int, _ component: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self)!
    }
}
