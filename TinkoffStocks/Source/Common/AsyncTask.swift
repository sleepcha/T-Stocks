//
//  AsyncTask.swift
//  T-Stocks
//
//  Created by sleepcha on 10/19/24.
//

import Foundation

// MARK: - AsyncTask

class AsyncTask<Output, Error: Swift.Error>: IdentifiableHashable {
    enum State {
        case ready
        case executing(AsyncTask)
        case success(Output)
        case failure(Error)
        case cancelled

        init(result: Result<Output, Error>) {
            self = switch result {
            case .success(let output): .success(output)
            case .failure(let error): .failure(error)
            }
        }
    }

    let id = UUID()
    var state: State { lock.withLock { _state } }

    var isCancelled: Bool {
        if case .cancelled = state { true }
        else { false }
    }

    private let label: String?
    private let lock = NSLock()
    private var block: ((AsyncTask) -> Void)?
    private var completionHandlers = [Handler<Result<Output, Error>>]()
    private var cancellationHandlers = [VoidHandler]()
    private var _state: State = .ready

    private var _isFinished: Bool {
        switch _state {
        case .success, .failure, .cancelled: true
        default: false
        }
    }

    /// You must manually signal the task completion by calling `$0.done(_:)` from inside the block.
    init(label: String? = nil, _ block: @escaping Handler<AsyncTask>) {
        self.label = label
        self.block = block
    }

    /// Creates an `AsyncTask` that completes immediately without performing any actual work.
    /// This method is useful in scenarios where a task is required but no action needs to be performed.
    static func empty(_ result: Result<Output, Error>) -> AsyncTask {
        AsyncTask { $0.done(result) }
    }

    /// Returns a new task that will have the current task as a dependency. This new task will be performed immediately after the current task completes successfully.
    /// The chain of tasks is started or cancelled by interacting with the last task in the chain.
    ///
    /// - Note: If the current task completes with an error, the chain is terminated, and the following tasks will not be executed.
    ///
    /// - Parameter nextTaskProvider: A closure that takes the output of the current task and returns the next task to be executed.
    /// - Returns: A new `AsyncTask` that represents the next step in the task chain.

    func then<NextOutput>(_ nextTaskProvider: @escaping (Output) -> AsyncTask<NextOutput, Error>) -> AsyncTask<NextOutput, Error> {
        let wrapperTask = AsyncTask<NextOutput, Error> { _ in
            // run the parent task
            self.run()
        }.onCancel {
            // cancel the parent task
            self.cancel()
        }

        lock.lock()
        defer { lock.unlock() }

        // ...and delegate finishing to the parent task's completion
        completionHandlers.append { [weak wrapperTask] result in
            guard let wrapperTask else { return }

            switch result {
            case .success(let output):
                let nextTask = nextTaskProvider(output)
                wrapperTask.onCancel(nextTask.cancel)
                nextTask.run { wrapperTask.done($0) }
            case .failure(let err):
                wrapperTask.done(.failure(err))
            }
        }

        return wrapperTask
    }

    /// Returns a new task that executes the current task mapping the original output using the given transformation.
    func map<NewOutput>(
        _ transform: @escaping (Output) -> NewOutput
    ) -> AsyncTask<NewOutput, Error> {
        AsyncTask<NewOutput, Error>(label: label) { newTask in
            self.run { newTask.done($0.map(transform)) }
        }.onCancel {
            self.cancel()
        }
    }

    /// Returns a new task that executes the current task mapping the original error using the given transformation.
    func mapError<NewError>(
        _ transform: @escaping (Error) -> NewError
    ) -> AsyncTask<Output, NewError> {
        AsyncTask<Output, NewError>(label: label) { newTask in
            self.run { newTask.done($0.mapError(transform)) }
        }.onCancel {
            self.cancel()
        }
    }

    /// Saves the closure that will execute when the task is cancelled. Will execute immediately if the task is already cancelled.
    @discardableResult
    func onCancel(_ handler: @escaping VoidHandler) -> Self {
        lock.withLock {
            if !_isFinished { cancellationHandlers.append(handler) }
        }
        return self
    }

    /// Saves a completion handler to be called when the task finishes successfully.
    @discardableResult
    func onSuccess(_ handler: @escaping Handler<Output>) -> Self {
        lock.withLock {
            guard !_isFinished else { return }

            completionHandlers.append { result in
                if case .success(let output) = result { handler(output) }
            }
        }
        return self
    }

    /// Saves a completion handler to be called when the task finishes with error.
    @discardableResult
    func onError(_ handler: @escaping Handler<Error>) -> Self {
        lock.withLock {
            guard !_isFinished else { return }

            completionHandlers.append { result in
                if case .failure(let error) = result { handler(error) }
            }
        }
        return self
    }

    /// Starts the task and ensures the completion handler is called when the task finishes.
    ///
    /// The task is keeping a strong reference to itself until it completes to prevent deallocation.
    /// If the task is currently executing, the completion handler is added to the collection of handlers that are called once the task finishes.
    /// If the task has already completed, the completion handler is called immediately with the task's result.
    ///
    /// - Parameter completion: An optional handler that is called when the task completes with a `Result` containing either the output or an error.
    func run(completion: Handler<Result<Output, Error>>? = nil) {
        guard tryChangeState(
            to: .executing(self),
            andExecute: { if let completion { completionHandlers.append(completion) } }
        )
        else {
            guard let completion else { return }

            lock.lock()
            switch _state {
            case .success(let output):
                lock.unlock()
                completion(.success(output))
                return
            case .failure(let error):
                lock.unlock()
                completion(.failure(error))
                return
            case .executing:
                completionHandlers.append(completion)
            default: break
            }

            lock.unlock()
            return
        }

        block?(self)
        block = nil
    }

    /// This method signals that the task has completed. The result is stored in the state, and all completion handlers are called with the result.
    func done(_ result: Result<Output, Error>) {
        guard tryChangeState(to: State(result: result)) else { return }
        for handler in completionHandlers { handler(result) }
        finish()
    }

    /// Finishes the task and calls cancellation handlers.
    func cancel() {
        guard tryChangeState(to: .cancelled) else { return }
        for handler in cancellationHandlers { handler() }
        finish()
    }

    private func finish() {
        lock.withLock {
            completionHandlers.removeAll()
            cancellationHandlers.removeAll()
        }
    }

    /// Synchronizes state switching and returns `true` if the switch was successful.
    private func tryChangeState(to newState: State, andExecute closure: VoidHandler = {}) -> Bool {
        lock.withLock {
            let isAllowed = switch (_state, newState) {
            case (.ready, .executing),
                 (.ready, .cancelled),
                 (.executing, .success),
                 (.executing, .failure),
                 (.executing, .cancelled):
                true
            default:
                false
            }

            if isAllowed {
                _state = newState
                closure()
            }
            return isAllowed
        }
    }
}

// MARK: - AsyncTask + group

extension AsyncTask {
    enum CancellationCondition {
        case never
        case always
        case when((Error) -> Bool)

        func check(_ error: Error) -> Bool {
            switch self {
            case .never:
                false
            case .always:
                true
            case .when(let condition):
                condition(error)
            }
        }
    }

    /// Runs a group of tasks concurrently, with an option to cancel the group when an error occurs, based on a specified condition.
    ///
    /// Tasks will continue executing until one of the tasks triggers a cancellation condition or until all tasks complete.
    /// Cancelling the group will also cancel all remaining tasks in the group.
    ///
    /// - Parameter tasks: An array of `AsyncTask` instances to be executed in parallel.
    /// - Parameter shouldCancelOnError: A `CancellationCondition` that defines when the group should cancel on error (default is `.never`).
    /// - Parameter maxConcurrentTaskCount: An optional limit on how many tasks can run concurrently.
    /// - Parameter taskQueue: An optional dispatch queue where tasks will be executed. If `nil`, tasks will run on a global concurrent queue.
    /// - Returns: An `AsyncTask` representing the group of tasks.
    static func group(
        _ tasks: [AsyncTask],
        shouldCancelOnError: CancellationCondition = .never,
        maxConcurrentTaskCount: Int? = nil,
        taskQueue: DispatchQueue? = nil
    ) -> AsyncTask<Void, Error> {
        let serialQueue = DispatchQueue(label: "AsyncTask.group.serialQueue")
        let taskQueue = taskQueue ?? DispatchQueue(label: "AsyncTask.group.taskQueue", attributes: .concurrent)
        let cancelAllTasks = {
            for task in tasks {
                taskQueue.async { task.cancel() }
            }
        }

        return AsyncTask<Void, Error>(label: "Group") { groupTask in
            let group = DispatchGroup()
            let groupLock = NSLock()
            let semaphore = maxConcurrentTaskCount.map(DispatchSemaphore.init)
            var abortingError: Error?

            for task in tasks {
                guard case .executing = groupTask.state else { break }

                // guarantee no state change until run() is dispatched
                task.lock.lock()
                defer { task.lock.unlock() }

                guard case .ready = task._state else { continue }

                task.cancellationHandlers.append {
                    semaphore?.signal()
                    group.leave()
                }
                task.completionHandlers.append {
                    defer {
                        semaphore?.signal()
                        group.leave()
                    }
                    guard let error = $0.failure else { return }

                    groupLock.withLock {
                        guard abortingError == nil, shouldCancelOnError.check(error) else { return }

                        abortingError = error
                        cancelAllTasks()
                    }
                }

                group.enter()

                guard let semaphore else {
                    taskQueue.async { task.run() }
                    continue
                }

                serialQueue.async {
                    // blocks only one thread on the serial queue
                    semaphore.wait()
                    taskQueue.async { task.run() }
                }
            }

            group.notify(queue: taskQueue) {
                let result: Result<Void, Error> = abortingError.map(Result.failure) ?? .success(())
                groupTask.done(result)
            }
        }.onCancel {
            cancelAllTasks()
        }
    }
}

// MARK: - AsyncTask + CustomDebugStringConvertible

extension AsyncTask: CustomDebugStringConvertible {
    var debugDescription: String {
        let label = label.map { ".\($0)" } ?? ""
        return "AsyncTask\(label) <\(id)>"
    }
}
