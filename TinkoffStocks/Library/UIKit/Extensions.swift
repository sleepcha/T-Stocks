//
//  UIKit+Extensions.swift
//  TinkoffStocks
//
//  Created by sleepcha on 8/23/23.
//

import UIKit

func onMain<T>(closure: () throws -> T) rethrows -> T {
    try Thread.isMainThread ? closure() : DispatchQueue.main.sync { try closure() }
}

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

// Live Preview for UIKit
#if DEBUG
    import SwiftUI

    extension UIView {
        @available(iOS 13, *)
        private struct Preview: UIViewRepresentable {
            typealias UIViewType = UIView
            let view: UIView

            func makeUIView(context: Context) -> UIView {
                view
            }

            func updateUIView(_ uiView: UIView, context: Context) {
                //
            }
        }

        @available(iOS 13, *)
        func showPreview() -> some View {
            Preview(view: self)
        }
    }

    extension UIViewController {
        @available(iOS 13, *)
        private struct Preview: UIViewControllerRepresentable {
            let viewController: UIViewController

            func makeUIViewController(context: Context) -> UIViewController {
                viewController
            }

            func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
                //
            }
        }

        @available(iOS 13, *)
        func showPreview() -> some View {
            Preview(viewController: self)
        }
    }
#endif
