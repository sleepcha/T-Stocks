//
//  GainState.swift
//  T-Stocks
//
//  Created by sleepcha on 9/28/24.
//

import UIKit

// MARK: - GainState

enum GainState {
    case profit
    case loss
    case neutral

    var sign: String {
        switch self {
        case .profit: "↑"
        case .loss: "↓"
        case .neutral: ""
        }
    }

    init(value: Decimal) {
        self = switch value.sign {
        case .plus: value.isZero ? .neutral : .profit
        case .minus: .loss
        }
    }
}

extension GainState {
    var textColor: UIColor {
        switch self {
        case .profit: .profit
        case .loss: .loss
        case .neutral: .neutral
        }
    }
}
