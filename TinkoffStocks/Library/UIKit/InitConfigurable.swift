//
//  InitConfigurable.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/9/24.
//

import UIKit

// MARK: - InitConfigurable

protocol InitConfigurable {
    init()
}

extension InitConfigurable {
    init(configuring: (Self) -> Void) {
        self.init()
        configuring(self)
    }
}

extension UIView: InitConfigurable {}
