//
//  Identifiable+Hashable.swift
//  T-Stocks
//
//  Created by sleepcha on 10/18/24.
//

import Foundation

// MARK: - IdentifiableHashable

protocol IdentifiableHashable: Identifiable & Hashable {}

extension IdentifiableHashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
