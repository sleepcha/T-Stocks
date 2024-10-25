import UIKit

// MARK: - ApplicationObserving

@objc protocol ApplicationObserving {
    @objc optional func didFinishLaunching(notification: Notification)
    @objc optional func didEnterBackground(notification: Notification)
    @objc optional func willEnterForeground(notification: Notification)
    @objc optional func didBecomeActive(notification: Notification)
    @objc optional func willResignActive(notification: Notification)
    @objc optional func willTerminate(notification: Notification)
    @objc optional func didReceiveMemoryWarning(notification: Notification)
    @objc optional func significantTimeChange(notification: Notification)
    @objc optional func backgroundRefreshStatusDidChange(notification: Notification)
    @objc optional func protectedDataWillBecomeUnavailable(notification: Notification)
    @objc optional func protectedDataDidBecomeAvailable(notification: Notification)
    @objc optional func userDidTakeScreenshot(notification: Notification)
}

extension ApplicationObserving where Self: UIResponder {
    func addApplicationObservers() {
        let nc = NotificationCenter.default
        let observers = [
            UIApplication.didFinishLaunchingNotification: #selector(didFinishLaunching),
            UIApplication.didEnterBackgroundNotification: #selector(didEnterBackground),
            UIApplication.willEnterForegroundNotification: #selector(willEnterForeground),
            UIApplication.didBecomeActiveNotification: #selector(didBecomeActive),
            UIApplication.willResignActiveNotification: #selector(willResignActive),
            UIApplication.willTerminateNotification: #selector(willTerminate),
            UIApplication.didReceiveMemoryWarningNotification: #selector(didReceiveMemoryWarning),
            UIApplication.significantTimeChangeNotification: #selector(significantTimeChange),
            UIApplication.backgroundRefreshStatusDidChangeNotification: #selector(backgroundRefreshStatusDidChange),
            UIApplication.protectedDataWillBecomeUnavailableNotification: #selector(protectedDataWillBecomeUnavailable),
            UIApplication.protectedDataDidBecomeAvailableNotification: #selector(protectedDataDidBecomeAvailable),
            UIApplication.userDidTakeScreenshotNotification: #selector(userDidTakeScreenshot),
        ]

        observers
            .filter { self.responds(to: $0.value) }
            .forEach { nc.addObserver(self, selector: $0.value, name: $0.key, object: nil) }
    }
}
