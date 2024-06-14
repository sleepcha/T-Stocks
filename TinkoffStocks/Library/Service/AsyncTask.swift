//
//  AsyncTask.swift
//  TinkoffStocks
//
//  Created by sleepcha on 12/15/23.
//

import Foundation

// MARK: - AsyncTask

final class AsyncTask: Identifiable {
    enum State {
        case ready
        case executing
        case completed
        case cancelled
        case failed

        var isFinished: Bool {
            switch self {
            case .completed, .cancelled, .failed: true
            default: false
            }
        }
    }

    private enum WrappedTask {
        case wrapped(() -> AsyncTask)
        case unwrapped(AsyncTask)

        var isWrapped: Bool {
            switch self {
            case .wrapped: true
            case .unwrapped: false
            }
        }

        mutating func unwrap() -> AsyncTask {
            switch self {
            case let .wrapped(closure):
                let task = closure()
                self = .unwrapped(task)
                return task
            case let .unwrapped(task):
                return task
            }
        }
    }

    let id = UUID()
    var state: State { lock.withLock { _state } }
    private(set) var error: Error?
    private var _state = State.ready
    private let lock = NSLock()
    private var queue = DispatchQueue.main

    private var block: ((AsyncTask) -> Void)?
    private var cancellationHandlers = [() -> Void]()
    private var finishHandler: ((Error?) -> Void)?
    private var chain = [WrappedTask]()
    private var rootTask: AsyncTask?

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
            queue.async { [block] in block!(self) }
            block = nil
        })
    }

    /// Adds another task to the chain of tasks that will be performed one after another.
    /// The chain execution breaks with any task finishing with error.
    /// You can also cancel the chain by cancelling the root task (the one you're adding tasks to).
    func then(_ taskClosure: @escaping () -> AsyncTask) -> AsyncTask {
        chain.append(.wrapped(taskClosure))
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

    /// Indicates that the task has finished. Passing an error will get it stored and propagated to the group task.
    /// It will also break the execution of the task chain if there is one.
    func done(error: Error? = nil) {
        switchState(
            to: (error == nil) ? .completed : .failed,
            andRun: {
                self.error = error
                finish()

                if _state == .completed, let task = nextChainTask() {
                    task.perform(on: queue)
                } else {
                    cleanUpChain()
                }
            }
        )
    }

    /// Finishes the task and calls cancellation handlers.
    /// If there are tasks in the chain, they will be cancelled as well.
    func cancel() {
        switchState(
            to: .cancelled,
            andRun: {
                for handler in cancellationHandlers {
                    queue.async { handler() }
                }
                finish()
            }
        )
        // must be called regardless of the root task's state
        lock.withLock { cleanUpChain(shouldCancel: true) }
    }

    private func finish() {
        finishHandler?(error)
        finishHandler = nil
        cancellationHandlers.removeAll()
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

    private func nextChainTask() -> AsyncTask? {
        let root = rootTask ?? self
        guard let index = root.chain.firstIndex(where: \.isWrapped) else { return nil }
        let task = root.chain[index].unwrap()
        task.rootTask = root
        return task
    }

    private func cleanUpChain(shouldCancel: Bool = false) {
        let root = rootTask ?? self
        guard !root.chain.isEmpty else { return }

        for case let .unwrapped(task) in root.chain {
            queue.async {
                task.rootTask = nil
                if shouldCancel { task.cancel() }
            }
        }
        root.chain.removeAll()
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

// MARK: - Equatable, CustomDebugStringConvertible

extension AsyncTask: Equatable, CustomDebugStringConvertible {
    static func == (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        lhs.id == rhs.id
    }

    var debugDescription: String {
        "AsyncTask <\(id.uuidString)>"
    }
}
