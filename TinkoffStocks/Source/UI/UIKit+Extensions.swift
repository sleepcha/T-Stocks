//
//  UIKit+Extensions.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/9/24.
//

import UIKit

extension UIStackView {
    convenience init(
        views: [UIView],
        axis: NSLayoutConstraint.Axis = .horizontal,
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        spacing: CGFloat = 0
    ) {
        self.init(arrangedSubviews: views)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }
}

extension UITableView {
    func register(_ cellType: UITableViewCell.Type) {
        register(cellType, forCellReuseIdentifier: String(describing: cellType))
    }

    func register(_ headerFooterViewType: UITableViewHeaderFooterView.Type) {
        register(headerFooterViewType, forHeaderFooterViewReuseIdentifier: String(describing: headerFooterViewType))
    }

    func dequeue<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withIdentifier: String(describing: cellType), for: indexPath) as? T
    }

    func dequeue<T: UITableViewHeaderFooterView>(_ headerFooterViewType: T.Type) -> T? {
        dequeueReusableHeaderFooterView(withIdentifier: String(describing: headerFooterViewType)) as? T
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cellType: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: T.self))
    }

    func dequeue<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T
    }
}

extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

extension Collection where Element: UIResponder {
    /// Useful for finding a specific subview.
    func first(ofType typeName: String) -> Element? {
        first { String(describing: type(of: $0)) == typeName }
    }
}

extension UIView {
    func shake() {
        let animationKey = "position"
        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()

        let animation = CABasicAnimation(keyPath: animationKey)
        animation.duration = 0.06
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = [center.x - 10, center.y]
        animation.toValue = [center.x + 10, center.y]

        feedback.notificationOccurred(.error)
        layer.add(animation, forKey: animationKey)
    }
}
