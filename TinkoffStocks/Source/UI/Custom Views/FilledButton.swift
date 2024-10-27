//
//  FilledButton.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/29/23.
//

import UIKit

class FilledButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .large
        configuration.cornerStyle = .large
        self.configuration = configuration
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
