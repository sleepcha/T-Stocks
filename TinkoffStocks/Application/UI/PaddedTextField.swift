//
//  PaddedTextField.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/11/23.
//

import Foundation
import UIKit

class PaddedTextField: UITextField {
    var padding: CGFloat = 16

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
        let leftViewWidth = rect.origin.x - padding
        let leftPadding = (leftViewWidth > 0 ? 8 : padding)
        let rightPadding = padding
        return rect.inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding))
    }

    private func calculateViewRect(forBounds bounds: CGRect, viewRect: CGRect, isLeftView: Bool = false) -> CGRect {
        let x = isLeftView ? padding : bounds.size.width - viewRect.width - padding
        let y = bounds.height / 2 - viewRect.height / 2
        return CGRect(origin: CGPointMake(x, y), size: viewRect.size)
    }
}
