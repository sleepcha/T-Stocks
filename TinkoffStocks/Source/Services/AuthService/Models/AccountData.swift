//
//  AccountData.swift
//  T-Stocks
//
//  Created by sleepcha on 7/23/24.
//

import Foundation

// MARK: - AccountData

struct AccountData {
    let id: String
    let name: String
    let openedDate: Date
    let isIIS: Bool
    let isReadOnly: Bool
}

// MARK: - Model mapping

extension AccountData {
    init?(from account: Account) {
        guard [.fullAccess, .readOnly].contains(account.accessLevel) else { return nil }

        self.init(
            id: account.id,
            name: account.name,
            openedDate: account.openedDate,
            isIIS: account.type == .tinkoffIis,
            isReadOnly: account.accessLevel == .readOnly
        )
    }
}
