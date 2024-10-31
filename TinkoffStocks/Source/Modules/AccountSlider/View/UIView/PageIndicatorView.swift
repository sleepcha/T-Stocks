//
//  PageIndicatorView.swift
//  T-Stocks
//
//  Created by sleepcha on 10/31/24.
//

import UIKit

final class PageIndicatorView: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: 100, height: 2)
    }

    var numberOfPages: Int = 0 {
        willSet {
            let newStep = (newValue == 0) ? 0 : 1 / CGFloat(newValue)
            position = newStep * min(CGFloat(newValue - 1), CGFloat(currentPage))
        }
        didSet {
            updateFrame()
            layoutIfNeeded()
        }
    }

    /// Current position in percentage points.
    var position: CGFloat = 0 {
        didSet {
            updateFrame()
            layoutIfNeeded()
        }
    }

    var currentPage: Int {
        Int(position * Double(numberOfPages))
    }

    private let indicatorView = UIView {
        $0.backgroundColor = .lightGray
    }

    private var indicatorWidth: CGFloat {
        guard numberOfPages > 0, frame.width > 0 else { return .zero }
        return 1 / Double(numberOfPages) * frame.width
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        indicatorView.layer.cornerRadius = frame.height / 2
        updateFrame()
    }

    private func setupViews() {
        backgroundColor = .white.withAlphaComponent(0.1)
        clipsToBounds = true
        addSubview(indicatorView)
    }

    private func updateFrame() {
        indicatorView.frame = CGRect(x: position * frame.width, y: 0, width: indicatorWidth, height: frame.height)
    }
}
