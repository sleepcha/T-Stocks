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
        self.configuration = .filled()
        configuration?.cornerStyle = .large
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
