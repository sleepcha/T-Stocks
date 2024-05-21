//
//  VerticalScrollView.swift
//  TinkoffStocks
//
//  Created by sleepcha on 3/21/24.
//

import UIKit

// MARK: - VerticalScrollView

class VerticalScrollView: UIScrollView {
    let contentView = UIView()
    
    private var keyboardInset: CGFloat = 0
    private var isKeyboardVisible: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        keyboardDismissMode = .interactive
        setupContentView()
        addKeyboardObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Scrolls to the subview frame origin or to the lowest point possible (if there is no more content below the view).
    ///
    /// To obtain the keyboard's height the method uses scroll view's `contentInset.bottom` which is set slightly *after* the keyboard begins showing up.
    /// So it is recommended to add a delay (150+ms) when used with keyboard-invoking logic (e.g. in `textFieldDidBeginEditing`).
    func scrollTo(_ subview: UIView, topInset: CGFloat = 20) {
        guard subview.isDescendant(of: self) else { return }

        var position = convert(subview.frame.origin, from: subview.superview)
        let targetViewToContentBottomDistance = contentSize.height - position.y
        let safeAreaHeight = frame.height - contentInset.bottom
        let offset = safeAreaHeight - targetViewToContentBottomDistance

        position.x = 0
        position.y -= (offset > 0) ? offset : topInset
        if position.y < 0 { position.y = 0 }
        setContentOffset(position, animated: true)
    }

    private func setupContentView() {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor),
        ])
    }
}

// MARK: - KeyboardObserving

extension VerticalScrollView: KeyboardObserving {
    // expand the scrollview by increasing `contentInset`
    @objc func keyboardWillShow(notification: Notification) {
        guard
            !isKeyboardVisible,
            let superview,
            let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
            let keyboardFrame = (keyboardValue as? NSValue)?.cgRectValue
        else { return }

        let keyboardTop = superview.convert(keyboardFrame, from: nil).minY
        let scrollViewBottom = superview.convert(frame, from: nil).maxY
        let overlap = scrollViewBottom - keyboardTop

        keyboardInset = (overlap > 0) ? overlap : 0
        isKeyboardVisible = true

        contentInset.bottom += keyboardInset
        scrollIndicatorInsets = contentInset
    }

    @objc func keyboardWillHide(notification: Notification) {
        guard isKeyboardVisible else { return }

        contentInset.bottom -= keyboardInset
        scrollIndicatorInsets = contentInset

        keyboardInset = 0
        isKeyboardVisible = false
    }
}
