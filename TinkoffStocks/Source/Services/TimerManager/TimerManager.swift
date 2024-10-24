//
//  TimerManager.swift
//  T-Stocks
//
//  Created by sleepcha on 9/13/24.
//

import Foundation

// MARK: - TimerManager

protocol TimerManager: AnyObject {
    func startTimer(timeInterval: TimeInterval, tolerance: TimeInterval, action: @escaping VoidHandler)
    func pause()
    func resume()
    func invalidateTimer()
}

// MARK: - TimerManagerImpl

final class TimerManagerImpl: TimerManager {
    private enum State {
        case invalid
        case running
        case paused(nextFireDate: Date)
    }

    private weak var timer: Timer?
    private var state = State.invalid

    func startTimer(timeInterval: TimeInterval, tolerance: TimeInterval, action: @escaping VoidHandler) {
        invalidateTimer()

        let timer = Timer(timeInterval: timeInterval, repeats: true) { _ in action() }
        timer.tolerance = tolerance
        self.timer = timer

        let runLoop = RunLoop.current
        runLoop.add(timer, forMode: .common)

        // runs RunLoop if this isn't the main thread
        if runLoop.currentMode == nil { runLoop.run() }

        state = .running
    }

    func invalidateTimer() {
        guard let timer else { return }

        timer.invalidate()
        state = .invalid

        #if DEBUG
        print("TimerManager.invalidateTimer()")
        #endif
    }

    func pause() {
        guard let timer, case .running = state else { return }
        print("paused")
        state = .paused(nextFireDate: timer.fireDate)
        timer.fireDate = .distantFuture
    }

    func resume() {
        guard let timer, case .paused(let nextFireDate) = state else { return }
        print("resumed")
        timer.fireDate = max(nextFireDate, .now)
        state = .running
    }

    deinit {
        invalidateTimer()
    }
}
