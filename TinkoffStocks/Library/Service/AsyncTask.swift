//
//  AsyncTask.swift
//  TinkoffStocks
//
//  Created by sleepcha on 12/15/23.
//

import Foundation

// MARK: - AsyncTask

final class AsyncTask {
    enum State: Equatable {
        case ready
        case executing
        case completed
        case cancelled
        /// Warning! The associated `Error` value is ignored in equality check.
        case failed(Error)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.ready, .ready),
                 (.executing, .executing),
                 (.completed, .completed),
                 (.cancelled, .cancelled),
                 (.failed, .failed):
                true
            default:
                false
            }
        }

        var isFinished: Bool {
            switch self {
            case .completed, .cancelled, .failed:
                true
            default:
                false
            }
        }
    }

    let id = UUID()
    var state: State { lock.withLock { _state } }
    private var _state = State.ready
    private let lock = NSLock()
    private var queue = DispatchQueue.main

    private var block: ((AsyncTask) -> Void)?
    private var cancellationHandlers = [() -> Void]()
    private var finishHandler: ((Error?) -> Void)?
    private var chain = [() -> AsyncTask]()

    /// Runs a group of tasks and collects each task's error until `shouldCancelOnError` closure returns `true`.
    static func group(
        _ tasks: [AsyncTask],
        shouldCancelOnError: ((Error) -> Bool)? = nil,
        completionQueue: DispatchQueue = .main,
        completion: @escaping ([Error]) -> Void
    ) -> AsyncTask {
        AsyncTask { groupTask in
            let group = DispatchGroup()
            let lock = NSLock()
            var abortingError: Error?
            var errors = [Error]()

            let onCancel = {
                for task in tasks {
                    groupTask.queue.async { task.cancel() }
                }
            }
            groupTask.addCancellationHandler(onCancel)

            for task in tasks {
                guard !groupTask.state.isFinished else { break }

                let isNotFinished = task.trySetFinishHandler { error in
                    defer { group.leave() }
                    guard let error else { return }

                    lock.withLock {
                        errors.append(error)
                        guard
                            abortingError == nil,
                            shouldCancelOnError?(error) == true
                        else { return }

                        abortingError = error
                        onCancel()
                    }
                }

                guard isNotFinished else { continue }

                group.enter()
                task.perform(on: groupTask.queue)
            }

            group.notify(queue: completionQueue) {
                completion(errors)
                groupTask.done(error: abortingError)
            }
        }
    }

    /// You must manually signal the task completion by calling `$0.done(error:)` from inside the block.
    init(_ block: @escaping (AsyncTask) -> Void) {
        self.block = block
    }

    /// Executes the block on the `queue`. The queue will also be used later to run cancellation handlers and chained tasks.
    func perform(on queue: DispatchQueue = .global(qos: .userInitiated)) {
        switchState(to: .executing, andRun: {
            self.queue = queue
            queue.async { [self] in
                guard state == .executing else { return }
                block?(self)
                block = nil
            }
        })
    }

    /// Adds another task to the chain of tasks that will be performed after the current task is done.
    func then(_ task: @escaping () -> AsyncTask) -> AsyncTask {
        chain.append(task)
        return self
    }

    /// Saves the closure that will execute if task is cancelled.
    func addCancellationHandler(_ handler: @escaping () -> Void) {
        lock.withLock {
            switch _state {
            case .cancelled:
                queue.async { handler() }
            case .ready, .executing:
                cancellationHandlers.append(handler)
            default:
                break
            }
        }
    }

    /// Indicates that the task has finished. Pass an error if you want it saved in the task state and propagated to the group task completion block
    func done(error: Error? = nil) {
        switchState(
            to: (error == nil) ? .completed : .failed(error!),
            andRun: {
                finish(with: error)
            }
        )
    }

    /// Finishes the task and calls `onCancel` closure.
    func cancel() {
        switchState(
            to: .cancelled,
            andRun: {
                for handler in cancellationHandlers {
                    queue.async { handler() }
                }
                finish(with: nil)
            }
        )
    }

    private func finish(with error: Error?) {
        finishHandler?(error)
        finishHandler = nil
        cancellationHandlers.removeAll()

        if let nextTask = chain.first?() {
            nextTask.chain = Array(chain.dropFirst())
            nextTask.perform(on: queue)
        }
    }

    @discardableResult
    private func switchState(to newState: State, andRun closure: () -> Void = {}) -> Bool {
        lock.withLock {
            let success = switch (_state, newState) {
            case (.ready, .executing),
                 (.ready, .cancelled),
                 (.executing, .completed),
                 (.executing, .cancelled),
                 (.executing, .failed):
                true
            default:
                false
            }

            if success {
                _state = newState
                closure()
            }

            return success
        }
    }

    private func trySetFinishHandler(_ handler: @escaping (Error?) -> Void) -> Bool {
        lock.withLock {
            guard !_state.isFinished else { return false }
            finishHandler = handler
            return true
        }
    }
}

extension AsyncTask {
    /// Convenience version of method for functional-style calls
    static func group(_ tasks: [AsyncTask]) -> AsyncTask {
        group(tasks) { _ in }
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
