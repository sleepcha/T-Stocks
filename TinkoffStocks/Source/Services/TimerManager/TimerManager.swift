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
        case paused
    }

    private let queue = DispatchQueue(label: "TimerManager.queue")
    private var timer: DispatchSourceTimer?
    private var state = State.invalid

    func schedule(timeInterval: TimeInterval, tolerance: TimeInterval, repeats: Bool, action: @escaping VoidHandler) {
        invalidateTimer()

        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.setEventHandler { print("fire the timer @ \(Date())"); action() }
        timer.schedule(
            deadline: .now() + timeInterval,
            repeating: repeats ? .init(timeInterval) : .never,
            leeway: .init(tolerance)
        )
        timer.activate()
        state = .running
        self.timer = timer
    }

    func invalidateTimer() {
        queue.sync {
            timer?.cancel()
            timer = nil
            state = .invalid
        }
    }

    func pause() {
        queue.sync {
            guard let timer, case .running = state else { return }
            timer.suspend()
            state = .paused
        }
    }

    func resume() {
        queue.sync {
            guard let timer, case .paused = state else { return }
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
