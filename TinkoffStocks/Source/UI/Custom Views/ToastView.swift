//
//  ToastView.swift
//  TinkoffStocks
//
//  Created by sleepcha on 4/2/24.
//

import UIKit

// MARK: - ToastView

final class ToastView: UIVisualEffectView {
    enum ToastSize: CGFloat {
        case small = 0.33
        case medium = 0.5
        case large = 0.66
    }

    enum ToastKind {
        case success
        case warning
        case error

        var iconName: String {
            switch self {
            case .success: "checkmark"
            case .warning: "exclamationmark.triangle"
            case .error: "xmark.square"
            }
        }

        var feedback: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: .success
            case .warning: .warning
            case .error: .error
            }
        }
    }

    private let scale: CGFloat
    private var keyboardHeight: CGFloat = 0

    private let label = UILabel {
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
        $0.textAlignment = .center
        $0.contentMode = .scaleToFill
        $0.textColor = .white
        $0.font = .preferredFont(forTextStyle: .headline)
    }

    private let icon = UIImageView {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
    }

    init(message: String, kind: ToastKind, size: ToastSize) {
        label.text = message
        icon.image = UIImage(systemName: kind.iconName)
        self.scale = size.rawValue

        super.init(effect: nil)
        setupViews()
        addKeyboardObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        keyboardHeight = window?.getKeyboardHeight() ?? 0
        updateBlurEffect()
        updateFrames()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #unavailable(iOS 17) {
            super.traitCollectionDidChange(previousTraitCollection)
            updateBlurEffect()
        }
    }

    private func setupViews() {
        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
                self.updateBlurEffect()
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIView.removeFromSuperview))
        addGestureRecognizer(tapGesture)
        autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
        layer.masksToBounds = true
        contentView.addSubview(icon)
        contentView.addSubview(label)
    }

    private func updateBlurEffect() {
        let isInDarkMode = (traitCollection.userInterfaceStyle == .dark)
        effect = UIBlurEffect(style: isInDarkMode ? .systemUltraThinMaterialDark : .systemThinMaterialDark)
    }

    private func updateFrames() {
        guard let superview else { return }

        let isKeyboardVisible = keyboardHeight > 0
        let isInLandscape = superview.bounds.width > superview.bounds.height
        let insets = UIEdgeInsets(
            top: superview.safeAreaInsets.top,
            left: 0,
            bottom: isKeyboardVisible ? keyboardHeight : superview.safeAreaInsets.bottom,
            right: 0
        )
        let safeArea = superview.bounds.inset(by: insets)
        let scale = (isKeyboardVisible && isInLandscape) ? scale * 1.5 : scale
        let side = min(safeArea.width, safeArea.height) * scale
        let mid = side / 2
        let newFrame = CGRectMake(safeArea.midX - mid, safeArea.midY - mid, side, side)

        guard frame != newFrame else { return }

        frame = newFrame
        layer.cornerRadius = side / 6.4

        let iconSize = side * 0.4
        icon.frame = CGRectMake(0, 0, iconSize, iconSize)
        icon.center = CGPoint(x: mid, y: side / 3)

        let inset = side * 0.08
        label.frame = bounds.inset(by: UIEdgeInsets(top: mid + inset * 0.67, left: inset, bottom: inset, right: inset))
    }
}

// MARK: - KeyboardObserving

extension ToastView: KeyboardObserving {
    func keyboardWillChangeFrame(notification: Notification) {
        guard
            let keyboardBeginValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey],
            let keyboardEndValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
            let kb1 = (keyboardBeginValue as? NSValue)?.cgRectValue,
            let kb2 = (keyboardEndValue as? NSValue)?.cgRectValue
        else { return }

        let dH = kb2.height - kb1.height
        let dY = kb2.minY - kb1.minY

        // types of orientation change with active keyboard:
        //
        // - show keyboard: dH != 0 (58/-kb2.h), dY < 0 (=-kb2.h)
        // - L-L start, hide keyboard: dH = 0, dY > 0 (=kb1.h =kb2.h)
        // - P-L start: dH < 0 (-54), dY > 0 (=kb1.h)
        // - L-P start: dH > 0 (67), dY > 0 (=kb1.h)
        // - L-L end: dH = 0, dY < 0 (=-kb2.h)
        // - P-L end: dH = 0, dY < 0 (=-kb2.h)
        // - L-P end: dH = 0, dY < 0 (=-kb2.h)

        let newKeyboardHeight: CGFloat? = switch (dH, dY) {
        // keyboard is showing
        case let (dH, dY) where dH != 0 && dY < 0: kb2.height

        // keyboard is hiding / landscape-to-landscape transition started
        case let (0, dY) where dY > 0: 0

        // landscape-to-landscape transition ended
        case let (0, dY) where dY < 0 && keyboardHeight == 0: kb2.height

        // orientation change started
        case let (dH, dY) where dY > 0: kb2.height + dH

        // irrelevant notifications
        default: nil
        }

        guard let newKeyboardHeight else { return }

        keyboardHeight = newKeyboardHeight
        updateFrames()
    }
}

// MARK: - UIViewController

extension UIViewController {
    func showToast(
        _ message: String,
        kind: ToastView.ToastKind,
        size: ToastView.ToastSize = .medium,
        willAutohide: Bool = true
    ) {
        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()

        let toast = ToastView(message: message, kind: kind, size: size)
        DispatchQueue.main.async {
            let view = self.navigationController?.view ?? self.view!
            view.addSubview(toast)
            feedback.notificationOccurred(kind.feedback)
        }

        guard willAutohide else { return }

        // long messages take more time to read
        let delay = 1.5 + Double(message.count) / 25

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // return if messageView has already been removed by tap
            guard toast.superview != nil else { return }

            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.curveEaseIn],
                animations: { toast.alpha = 0 },
                completion: { _ in toast.removeFromSuperview() }
            )
        }
    }
}

// MARK: Helpers

private extension UIWindow {
    func getKeyboardHeight() -> CGFloat {
        guard
            let keyboardWindow = windowScene?.windows.first(ofType: "UITextEffectsWindow"),
            let keyboardView = keyboardWindow.rootViewController?.view.subviews.first(ofType: "UIInputSetHostView"),
            // keyboard isn't hidden (not off-screen)
            keyboardView.frame.origin.y < keyboardWindow.frame.maxY
        else { return 0 }

        return keyboardView.bounds.height
    }
}
