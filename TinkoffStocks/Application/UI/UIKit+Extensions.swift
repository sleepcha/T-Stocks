//
//  UIKit+Extensions.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/9/24.
//

import UIKit

extension UITableView {
    func register(_ cellType: UITableViewCell.Type) {
        register(cellType, forCellReuseIdentifier: String(describing: cellType))
    }

    func dequeue<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withIdentifier: String(describing: cellType), for: indexPath) as? T
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
    func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }

    func bold() -> UIFont {
        with(traits: .traitBold)
    }

    func italic() -> UIFont {
        with(traits: .traitItalic)
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
