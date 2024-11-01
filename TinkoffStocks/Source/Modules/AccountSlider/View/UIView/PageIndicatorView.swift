//
//  PageIndicatorView.swift
//  T-Stocks
//
//  Created by sleepcha on 10/31/24.
//

import UIKit

// MARK: - PageIndicatorView

final class PageIndicatorView: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: 100, height: 2)
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

    private let indicatorView = UIView()

    private(set) var numberOfPages: Int = 0
    private var indicatorWidth: CGFloat {
        guard numberOfPages > 0, frame.width > 0 else { return 0 }
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

    func setNumberOfPages(_ newValue: Int, updatingPosition: Bool) {
        if updatingPosition {
            let newStep = (newValue == 0) ? 0 : 1 / CGFloat(newValue)
            position = newStep * min(CGFloat(newValue - 1), CGFloat(currentPage))
        }

        numberOfPages = newValue
        isHidden = numberOfPages < 2
        updateFrame()
        layoutIfNeeded()
    }

    private func setupViews() {
        indicatorView.backgroundColor = C.indicatorColor
        backgroundColor = C.indicatorColor.withAlphaComponent(0.18)
        isHidden = true
        clipsToBounds = true
        addSubview(indicatorView)
    }

    private func updateFrame() {
        indicatorView.frame = CGRect(x: position * frame.width, y: 0, width: indicatorWidth, height: frame.height)
    }
}

// MARK: - Constants

private extension C {
    static let indicatorColor = UIColor(red: 0.77, green: 0.78, blue: 0.79, alpha: 1)
}
