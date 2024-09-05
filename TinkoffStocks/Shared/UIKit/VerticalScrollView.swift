import UIKit

// MARK: - VerticalScrollView

final class VerticalScrollView: UIScrollView {
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
    /// It is recommended to add a delay (100+ms) when used with keyboard-invoking logic (e.g. in `textFieldDidBeginEditing`).
    func scrollTo(_ subview: UIView, topOffset: CGFloat = 24) {
        guard subview.isDescendant(of: self) else { return }

        let maxVerticalOffset = contentView.bounds.height + contentInset.bottom - bounds.height
        var y = convert(subview.frame.origin, from: subview.superview).y
        y = min(y - topOffset, maxVerticalOffset)
        y = max(y, 0)

        setContentOffset(CGPointMake(0, y), animated: true)
    }

    private func setupContentView() {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor),
        ])
    }
}

extension VerticalScrollView: KeyboardObserving {
    // compresses the scrollView by increasing `contentInset.bottom`
    @objc func keyboardWillShow(notification: Notification) {
        guard
            !isKeyboardVisible,
            let superview,
            let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
            let keyboardFrame = (keyboardValue as? NSValue)?.cgRectValue
        else { return }

        let keyboardTop = keyboardFrame.minY
        let scrollViewBottom = superview.convert(frame, to: nil).maxY
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
