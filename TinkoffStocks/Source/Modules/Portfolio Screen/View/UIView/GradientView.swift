//
//  GradientView.swift
//  T-Stocks
//
//  Created by sleepcha on 10/1/24.
//

import UIKit

class GradientView: UIView {
    private let mainColor: UIColor
    private let accentColor: UIColor

    private var offsetY: CGFloat = 0
    private lazy var gradient = CAGradientLayer {
        $0.type = .radial
        $0.colors = [accentColor.cgColor, mainColor.cgColor]
        $0.locations = [0, 1]
        $0.startPoint = CGPoint(x: 1.05, y: 0.5)
        $0.endPoint = CGPoint(x: 2.05, y: 1)
        $0.drawsAsynchronously = true
        $0.shouldRasterize = true
        $0.isOpaque = true
    }

    init(mainColor: UIColor, accentColor: UIColor) {
        self.accentColor = accentColor
        self.mainColor = mainColor
        super.init(frame: .zero)

        self.backgroundColor = mainColor
        clipsToBounds = true
        layer.isOpaque = true
        layer.shouldRasterize = true
        layer.rasterizationScale = 3
        layer.addSublayer(gradient)

        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(updateColors))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setGradientOffset(offsetY)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #unavailable(iOS 17) {
            super.traitCollectionDidChange(previousTraitCollection)
            updateColors()
        }
    }

    func setGradientOffset(_ offset: CGFloat) {
        offsetY = offset
        let width = bounds.width
        let height = (width > bounds.height) ? width : width * 2
        gradient.frame = CGRect(x: 0, y: bounds.height - height + offsetY, width: width, height: height)
        gradient.removeAllAnimations()
    }

    @objc private func updateColors() {
        gradient.colors = [accentColor.cgColor, mainColor.cgColor]
    }
}
