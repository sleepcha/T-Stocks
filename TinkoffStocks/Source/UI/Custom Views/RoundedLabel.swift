//
//  RoundedLabel.swift
//  T-Stocks
//
//  Created by sleepcha on 9/28/24.
//

import UIKit

final class RoundedLabel: UILabel {
    private var insets: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: insets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + 1.05 * (insets.left + insets.right),
            height: 1.5 * size.height
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .secondarySystemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }

    private func updateCornerRadius() {
        let newCornerRadius = frame.height / 2
        if newCornerRadius != layer.cornerRadius {
            layer.cornerRadius = newCornerRadius

            let padding = frame.height * 0.333
            insets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            invalidateIntrinsicContentSize()
        }
    }
}
