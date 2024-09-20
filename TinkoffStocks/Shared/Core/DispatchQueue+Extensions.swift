import Foundation

public extension DispatchQueue {
    /// Safer version of `.main.sync` that prevents a potential deadlock.
    @discardableResult
    static func mainSync<T>(closure: () throws -> T) rethrows -> T {
        try Thread.isMainThread ? closure() : main.sync { try closure() }
    }

    static func mainAsync(closure: @escaping () -> Void) {
        Thread.isMainThread ? closure() : main.async { closure() }
    }
}
