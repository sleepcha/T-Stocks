//
//  AsyncTask.swift
//  TinkoffStocks
//
//  Created by sleepcha on 12/15/23.
//

import Foundation

// MARK: - AsyncTask

class AsyncTask: Identifiable {
    enum State: Equatable {
        case ready
        case executing
        case completed
        case cancelled
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
    }

    let id = UUID()
    var state: State { lock.withLock { _state } }

    fileprivate let lock = NSLock()
    fileprivate var queue = DispatchQueue.main
    fileprivate var finishHandler: ((Error?) -> Void)?

    private var _state = State.ready
    private var block: ((AsyncTask) -> Void)!
    private var cancellationHandlers = [() -> Void]()

    static func empty() -> AsyncTask {
        AsyncTask { $0.done() }
    }

    /// You must manually signal the task completion by calling `$0.done(error:)` from inside the block.
    init(_ block: @escaping (AsyncTask) -> Void) {
        self.block = block
    }

    /// Executes the block on the `queue`. The queue will also be used to run cancellation handlers.
    func perform(on queue: DispatchQueue = .global(qos: .userInitiated)) {
        trySwitchState(to: .executing) {
            self.queue = queue
            queue.async { [self] in
                block(self)
                block = nil
            }
        }
    }

    /// Indicates that the task has finished. Passing an error will get it stored and propagated to the group task.
    /// It will also break the execution of the task chain if there is one.
    func done(error: Error? = nil) {
        trySwitchState(to: (error == nil) ? .completed : .failed(error!)) {
            finish(with: error)
        }
    }

    /// Finishes the task and calls cancellation handlers.
    func cancel() {
        trySwitchState(to: .cancelled) {
            for handler in cancellationHandlers.reversed() {
                queue.async { handler() }
            }
            finish(with: nil)
        }
    }

    /// Saves the closure that will execute when the task is cancelled. Will execute immediately if the task is already cancelled.
    func addCancellationHandler(_ handler: @escaping () -> Void) {
        ifStateIs([.ready, .executing]) { cancellationHandlers.append(handler) }
    }

    fileprivate func finish(with error: Error?) {
        finishHandler?(error)
        finishHandler = nil
        cancellationHandlers.removeAll()
    }

    /// Synchronizes execution of a closure if the current task state is in one of the specified states.
    @discardableResult
    fileprivate func ifStateIs(_ states: [State], execute closure: () -> Void) -> Bool {
        lock.withLock {
            if states.contains(_state) {
                closure()
                return true
            } else {
                return false
            }
        }
    }

    private func trySwitchState(to newState: State, andExecute closure: () -> Void = {}) {
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
        }
    }
}

// MARK: - Equatable, CustomDebugStringConvertible

extension AsyncTask: Equatable, CustomDebugStringConvertible {
    static func == (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        lhs.id == rhs.id
    }

    var debugDescription: String {
        "\(type(of: self)) <\(id.uuidString)>"
    }
}

// MARK: - AsyncChain

final class AsyncChain: AsyncTask {
    typealias AsyncTaskProvider = () -> AsyncTask

    private var chain = LinkedList<AsyncTaskProvider>()
    private var completion: ((State) -> Void)?

    private static func performChain(rootTask: AsyncChain) {
        guard case .executing = rootTask.state else { return }

        guard let subTask = rootTask.chain.popFirst()?() else {
            // no more tasks in the chain
            rootTask.done()
            return
        }

        let isReady = subTask.ifStateIs([.ready]) {
            subTask.finishHandler = { error in
                if let error {
                    rootTask.done(error: error)
                } else {
                    performChain(rootTask: rootTask)
                }
            }
            rootTask.addCancellationHandler(subTask.cancel)
        }

        isReady ? subTask.perform(on: rootTask.queue) : rootTask.cancel()
    }

    init(_ taskClosure: @escaping AsyncTaskProvider) {
        chain.append(taskClosure)
        super.init { task in
            Self.performChain(rootTask: task as! AsyncChain)
        }
    }

    /// Adds another task to the chain of tasks that will be performed one after another.
    ///
    /// The chain execution breaks with any task completing with error (or starting off with a non-ready state).
    /// You can also cancel the chain by cancelling the root task (the one you're adding tasks to).
    func then(_ taskClosure: @escaping AsyncTaskProvider) -> AsyncChain {
        ifStateIs([.ready, .executing]) { chain.append(taskClosure) }
        return self
    }

    /// Sets the closure that will handle the completion of the chain.
    func handle(_ completion: @escaping (State) -> Void) -> AsyncTask {
        ifStateIs([.ready, .executing]) { self.completion = completion }
        return self
    }

    override fileprivate func finish(with error: Error?) {
        super.finish(with: error)
        queue.async { [self] in
            completion?(state)
            completion = nil
        }
        chain.removeAll()
    }
}

// MARK: - AsyncGroup

final class AsyncGroup: AsyncTask {
    /// Runs a group of tasks and collects each task's error until `shouldCancelOnError` closure returns `true`.
    init(
        _ tasks: [AsyncTask],
        shouldCancelOnError: ((Error) -> Bool)? = nil,
        completionQueue: DispatchQueue = .main,
        completion: @escaping ([Error]) -> Void
    ) {
        super.init { groupTask in
            let group = DispatchGroup()
            let groupLock = NSLock()
            var abortingError: Error?
            var errors = [Error]()

            let onCancel = {
                for task in tasks {
                    groupTask.queue.async { task.cancel() }
                }
            }
            groupTask.addCancellationHandler(onCancel)

            for task in tasks {
                guard case .executing = groupTask.state else { break }

                task.ifStateIs([.ready]) {
                    group.enter()
                    task.finishHandler = { error in
                        defer { group.leave() }
                        guard let error else { return }

                        groupLock.withLock {
                            errors.append(error)
                            guard
                                abortingError == nil,
                                shouldCancelOnError?(error) == true
                            else { return }

                            abortingError = error
                            onCancel()
                        }
                    }
                }
                task.perform(on: groupTask.queue)
            }

            group.notify(queue: completionQueue) {
                completion(errors)
                groupTask.done(error: abortingError)
            }
        }
    }

    /// Convenience version for functional-style calls
    convenience init(_ tasks: [AsyncTask]) {
        self.init(tasks) { _ in }
    }
}
