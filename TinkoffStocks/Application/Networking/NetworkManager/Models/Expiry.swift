//
//  Expiry.swift
//  T-Stocks
//
//  Created by sleepcha on 7/20/24.
//

import Foundation

enum Expiry {
    typealias DateProvider = () -> Date

    enum Period {
        case second(Int)
        case minute(Int)
        case hour(Int)
        case day(Int)
        case month(Int)

        func expiration(for creationDate: Date) -> Date {
            switch self {
            case let .second(value): creationDate.adding(value, .second)
            case let .minute(value): creationDate.adding(value, .minute)
            case let .hour(value): creationDate.adding(value, .hour)
            case let .day(value): creationDate.adding(value, .day)
            case let .month(value): creationDate.adding(value, .month)
            }
        }
    }

    case `for`(Period)
    case until(deadline: DateProvider)
    case forever
}
