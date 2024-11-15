//
//  TimerManager.swift
//  T-Stocks
//
//  Created by sleepcha on 9/13/24.
//

import Foundation

// MARK: - TimerManager

protocol TimerManager: AnyObject {
    func schedule(timeInterval: TimeInterval, tolerance: TimeInterval, repeats: Bool, action: @escaping VoidHandler)
    func pause()
    func resume()
    func invalidateTimer()
}

// MARK: - TimerManagerImpl

final class TimerManagerImpl: TimerManager {
    private enum State {
        case invalid
        case running
        case suspended
    }

    private let queue = DispatchQueue(label: "TimerManager.serialQueue")
    private var timer: DispatchSourceTimer?
    private var state = State.invalid

    func schedule(timeInterval: TimeInterval, tolerance: TimeInterval, repeats: Bool, action: @escaping VoidHandler) {
        invalidateTimer()

        queue.sync {
            let timer = DispatchSource.makeTimerSource(queue: .global())
            timer.setEventHandler(handler: action)
            timer.schedule(
                deadline: .now() + timeInterval,
                repeating: repeats ? DispatchTimeInterval(timeInterval) : .never,
                leeway: DispatchTimeInterval(tolerance)
            )
            timer.activate()
            self.timer = timer
            state = .running
        }
    }

    func invalidateTimer() {
        queue.sync {
            guard let timer = self.timer else { return }
            if case .suspended = state { timer.resume() }
            timer.cancel()
            self.timer = nil
            state = .invalid
        }
    }

    func pause() {
        queue.sync {
            guard let timer, case .running = state else { return }
            timer.suspend()
            state = .suspended
        }
    }

    func resume() {
        queue.sync {
            guard let timer, case .suspended = state else { return }
            timer.resume()
            state = .running
        }
    }

    deinit {
        invalidateTimer()
    }
}

// MARK: - Helpers

extension DispatchTimeInterval {
    init(_ timeInterval: TimeInterval) {
        self = .nanoseconds(Int(timeInterval * 1_000_000_000))
    }
}
