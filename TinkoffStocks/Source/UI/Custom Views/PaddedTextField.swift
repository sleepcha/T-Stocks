//
//  PaddedTextField.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/11/23.
//

import UIKit

final class PaddedTextField: UITextField {
    var padding: CGFloat = 16
    private let textToOverlayViewsPadding: CGFloat = 4

    private var _clearButton: UIView?
    private var clearButton: UIView? {
        _clearButton = _clearButton ?? subviews.first(ofType: "_UITextFieldClearButton")
        return _clearButton
    }

    override var isEnabled: Bool {
        didSet {
            let alphaValue = isEnabled ? 1 : 0.25
            textColor = textColor?.withAlphaComponent(alphaValue)
            leftView?.alpha = alphaValue
            rightView?.alpha = alphaValue
            clearButton?.alpha = alphaValue
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        calculateTextRect(super.textRect(forBounds: bounds))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        calculateTextRect(super.editingRect(forBounds: bounds))
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let leftView else { return .zero }
        return calculateViewRect(forBounds: bounds, viewRect: leftView.bounds, isLeftView: true)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let rightView else { return .zero }
        return calculateViewRect(forBounds: bounds, viewRect: rightView.bounds)
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        guard clearButtonMode != .never else { return .zero }
        let clearButtonRect = super.clearButtonRect(forBounds: bounds)
        return calculateViewRect(forBounds: bounds, viewRect: clearButtonRect)
    }

    private func calculateTextRect(_ rect: CGRect) -> CGRect {
        guard rect.size != CGSizeMake(100, 100) else { return rect }

        let isLeftViewVisible = rect.origin.x > padding
        let isRightViewVisible = bounds.width - rect.width != 0
        let leftPadding = isLeftViewVisible ? textToOverlayViewsPadding : padding
        let rightPadding = padding + (isRightViewVisible ? textToOverlayViewsPadding : 0)

        return rect.inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding))
    }

    private func calculateViewRect(forBounds bounds: CGRect, viewRect: CGRect, isLeftView: Bool = false) -> CGRect {
        let x = isLeftView ? padding : bounds.width - viewRect.width - padding
        let y = bounds.height / 2 - viewRect.height / 2
        return CGRect(origin: CGPointMake(x, y), size: viewRect.size)
    }
}
