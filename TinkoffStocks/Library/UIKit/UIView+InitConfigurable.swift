//
//  UIView+InitConfigurable.swift
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
    init(configure: (Self) -> Void) {
        self.init()
        configure(self)
    }
}

extension UIView: InitConfigurable {}
