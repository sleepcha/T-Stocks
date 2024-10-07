//
//  RateLimitManager.swift
//  T-Stocks
//
//  Created by sleepcha on 8/19/24.
//

import Foundation

final class RateLimitManager {
    private let now: () -> Date
    private let lock = NSLock()
    private var rateLimitResetDate: Date?

    init(dateProvider: @escaping () -> Date) {
        self.now = dateProvider
    }

    func setResetInterval(_ waitTime: TimeInterval) {
        lock.withLock { rateLimitResetDate = now().addingTimeInterval(waitTime) }
    }

    func getResetInterval() -> TimeInterval? {
        if let waitTime = lock.read(rateLimitResetDate)?.timeIntervalSince(now()), waitTime > 0 {
            return waitTime
        } else {
            lock.withLock { rateLimitResetDate = nil }
            return nil
        }
    }
}
