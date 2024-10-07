import UIKit

// MARK: - KeyboardObserving

@objc protocol KeyboardObserving {
    @objc optional func keyboardWillShow(notification: Notification)
    @objc optional func keyboardDidShow(notification: Notification)
    @objc optional func keyboardWillHide(notification: Notification)
    @objc optional func keyboardDidHide(notification: Notification)
    @objc optional func keyboardWillChangeFrame(notification: Notification)
    @objc optional func keyboardDidChangeFrame(notification: Notification)
}

extension KeyboardObserving where Self: UIResponder {
    func addKeyboardObservers() {
        let nc = NotificationCenter.default
        let observers = [
            UIResponder.keyboardWillShowNotification: #selector(keyboardWillShow),
            UIResponder.keyboardDidShowNotification: #selector(keyboardDidShow),
            UIResponder.keyboardWillHideNotification: #selector(keyboardWillHide),
            UIResponder.keyboardDidHideNotification: #selector(keyboardDidHide),
            UIResponder.keyboardWillChangeFrameNotification: #selector(keyboardWillChangeFrame),
            UIResponder.keyboardDidChangeFrameNotification: #selector(keyboardDidChangeFrame),
        ]

        observers
            .filter { responds(to: $0.value) }
            .forEach { nc.addObserver(self, selector: $0.value, name: $0.key, object: nil) }
    }
}
