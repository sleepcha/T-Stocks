//
//  UIStackView+Extension.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/16/24.
//

import UIKit

extension UIStackView {
    convenience init(
        views: [UIView],
        axis: NSLayoutConstraint.Axis = .horizontal,
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        spacing: CGFloat = 0
    ) {
        self.init(arrangedSubviews: views)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }
}
