import UIKit

// MARK: - ApplicationObserving

@objc protocol ApplicationObserving {
    @objc optional func didFinishLaunching()
    @objc optional func didEnterBackground()
    @objc optional func willEnterForeground()
    @objc optional func didBecomeActive()
    @objc optional func willResignActive()
    @objc optional func willTerminate()
    @objc optional func didReceiveMemoryWarning()
    @objc optional func significantTimeChange()
    @objc optional func backgroundRefreshStatusDidChange()
    @objc optional func protectedDataWillBecomeUnavailable()
    @objc optional func protectedDataDidBecomeAvailable()
    @objc optional func userDidTakeScreenshot()
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
