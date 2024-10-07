//
//  TimerManager.swift
//  T-Stocks
//
//  Created by sleepcha on 9/13/24.
//

import Foundation

// MARK: - TimerManager

protocol TimerManager {
    func scheduleTimer(timeInterval: TimeInterval, tolerance: TimeInterval, action: @escaping VoidHandler)
    func invalidateTimer()
}

// MARK: - TimerManagerImpl

final class TimerManagerImpl: TimerManager {
    private weak var timer: Timer?

    func scheduleTimer(timeInterval: TimeInterval, tolerance: TimeInterval, action: @escaping VoidHandler) {
        let timer = Timer(timeInterval: timeInterval, repeats: true) { _ in action() }
        timer.tolerance = tolerance
        self.timer = timer

        let runLoop = RunLoop.current
        runLoop.add(timer, forMode: .common)

        // runs RunLoop if this isn't the main thread
        if runLoop.currentMode == nil { runLoop.run() }
    }

    func invalidateTimer() {
        timer?.invalidate()

        #if DEBUG
        print("TimerProvider.invalidateTimer()")
        #endif
    }

    deinit {
        invalidateTimer()
    }
}
