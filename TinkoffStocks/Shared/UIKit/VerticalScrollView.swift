import UIKit

final class VerticalScrollView: UIScrollView {
    let contentView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        keyboardDismissMode = .interactive
        setupContentView()
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
