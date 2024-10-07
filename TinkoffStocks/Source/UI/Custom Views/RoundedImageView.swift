//
//  RoundedImageView.swift
//  T-Stocks
//
//  Created by sleepcha on 9/15/24.
//

import UIKit

final class RoundedImageView: UIImageView {
    var cornerRadiusRatio: CGFloat = 0 {
        didSet {
            cornerRadiusRatio = min(max(cornerRadiusRatio, 0), 1)
            updateCornerRadius()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }

    private func updateCornerRadius() {
        let newCornerRadius = frame.height * cornerRadiusRatio
        if newCornerRadius != layer.cornerRadius { layer.cornerRadius = newCornerRadius }
    }
}
