//
//  AsyncTask.swift
//  BondsFilter
//
//  Created by sleepcha on 12/15/23.
//

import Foundation

// MARK: - AsyncTask

final class AsyncTask {
    enum TaskError: Error {
        case cancelled
    }

    enum State: String {
        case ready, executing, done, cancelled
    }

    let id = UUID()
    /// The closure that will execute if task was cancelled.
    var onCancel: (() -> Void)?

    private let lock = NSLock()
    private var state = State.ready
    private var block: ((AsyncTask) -> Void)?
    private var cancelBlock: (() -> Void)?
    private var finishBlock: ((Error?) -> Void)?

    /// You must manually signal the task completion by calling `$0.done(error:)` from inside the block.
    init(_ block: @escaping (AsyncTask) -> Void) {
        self.block = block
    }

    /// Executes the block on the `queue`.
    func perform(on queue: DispatchQueue = .global()) {
        switchState(to: .executing, andRun: {
            queue.async { [self] in
                if self.is(.executing) { block?(self) }
            }
        })
    }

    /// Indicates that the task has finished. Pass an error if you want it propagated to the group / chain task completion block.
    func done(error: Error? = nil) {
        guard switchState(to: .done) else { return }
        finish(with: error)
    }

    /// Finishes the task and calls `onCancel` closure.
    func cancel() {
        guard switchState(to: .cancelled) else { return }
        onCancel?()
        cancelBlock?()
        finish(with: TaskError.cancelled)
    }

    /// Returns true if the task is currently in the specified state.
    func `is`(_ someState: State) -> Bool {
        lock.withLock { state == someState }
    }

    private func finish(with error: Error?) {
        finishBlock?(error)
        finishBlock = nil
        block = nil
        onCancel = nil
        cancelBlock = nil
    }

    @discardableResult
    private func switchState(to newState: State, andRun closure: (() -> Void)? = nil) -> Bool {
        lock.withLock {
            let success = switch (state, newState) {
            case (.ready, .executing): true
            case (.ready, .cancelled): true
            case (.executing, .done): true
            case (.executing, .cancelled): true
            default: false
            }

            if success {
                state = newState
                closure?()
            }

            return success
        }
    }
}

// MARK: - Group, chain

extension AsyncTask {
    static func group(
        _ tasks: [AsyncTask],
        queue: DispatchQueue = .global(),
        completionQueue: DispatchQueue = .main,
        cancelOnFirstError: ((Error) -> Bool)? = nil,
        completion: @escaping ([Error]) -> Void
    ) -> AsyncTask {
        AsyncTask { groupTask in
            let group = DispatchGroup()
            let lock = NSLock()
            var abortingError: Error?
            var errors = [Error]()

            let cancelAll = { (reason: Error) in
                lock.withLock { abortingError = abortingError ?? reason }
                tasks.forEach { $0.cancel() }
            }

            groupTask.cancelBlock = { cancelAll(TaskError.cancelled) }

            for task in tasks {
                if task.is(.cancelled) { continue }
                task.finishBlock = { error in
                    defer { group.leave() }
                    guard let error, error as? TaskError != .cancelled else { return }
                    lock.withLock { errors.append(error) }
                    if cancelOnFirstError?(error) == true { cancelAll(error) }
                }
                group.enter()
                task.perform(on: queue)
            }

            group.notify(queue: completionQueue) {
                completion(errors)
                groupTask.done(error: abortingError)
            }
        }
    }

    /// Using task-returning closures instead of plain tasks allows to delay task's creation (e.g. if data for some argument becomes available only after preceding tasks are finished)
    static func chain(
        _ tasks: [() -> AsyncTask],
        queue: DispatchQueue = .global(),
        completionQueue: DispatchQueue = .main,
        completion: ((Error?) -> Void)? = nil
    ) -> AsyncTask {
        func recursiveTask(mainTask: AsyncTask, index: Int = 0) {
            guard !mainTask.is(.cancelled) else {
                completionQueue.async { completion?(TaskError.cancelled) }
                return
            }
            guard index < tasks.count else {
                completionQueue.async { completion?(nil) }
                mainTask.done()
                return
            }

            let task = tasks[index]()
            mainTask.cancelBlock = task.cancel
            task.finishBlock = { error in
                if let error {
                    completionQueue.async { completion?(error) }
                    mainTask.done(error: error)
                } else {
                    recursiveTask(mainTask: mainTask, index: index + 1)
                }
            }
            task.perform(on: queue)
        }

        return AsyncTask { chainTask in recursiveTask(mainTask: chainTask) }
    }

    static func chain(
        _ tasks: [AsyncTask],
        queue: DispatchQueue = .global(),
        completionQueue: DispatchQueue = .main,
        completion: ((Error?) -> Void)? = nil
    ) -> AsyncTask {
        chain(
            tasks.map { task in { task } },
            queue: queue,
            completionQueue: completionQueue,
            completion: completion
        )
    }

    static func empty() -> AsyncTask {
        AsyncTask { $0.done() }
    }
}

// MARK: - Identifiable, CustomDebugStringConvertible

extension AsyncTask: Identifiable, CustomDebugStringConvertible {
    var debugDescription: String {
        "AsyncTask <\(id.uuidString)>"
    }
}
