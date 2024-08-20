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

    let id: UUID
    var state: State { lock.withLock { _state } }

    fileprivate var finishHandler: ((Error?) -> Void)?
    fileprivate let lock = NSLock()
    fileprivate(set) var queue = DispatchQueue.main

    private var block: ((AsyncTask) -> Void)?
    private var cancellationHandlers = [() -> Void]()
    private var _state = State.ready

    /// You must manually signal the task completion by calling `$0.done(error:)` from inside the block.
    init(id: UUID = .init(), _ block: @escaping (AsyncTask) -> Void) {
        self.id = id
        self.block = block
    }

    /// Creates an `AsyncTask` that immediately completes without performing any actual work (except the completion handler).
    /// The method is useful in scenarios where a task must be returned but no action is necessary.
    static func empty(error: Error? = nil, completion: (() -> Void)? = nil) -> AsyncTask {
        AsyncTask {
            completion?()
            $0.done(error: error)
        }
    }

    /// Executes the block on the `queue`. The queue will also be used to run cancellation handlers.
    func perform(on queue: DispatchQueue = .global(qos: .userInitiated), delay: TimeInterval = 0) {
        trySwitchState(to: .executing) {
            self.queue = queue
            queue.asyncAfter(deadline: .now() + delay) { [self] in
                block?(self)
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
        let didAddHandler = ifStateIs([.ready, .executing]) { cancellationHandlers.append(handler) }
        if !didAddHandler, state == .cancelled { handler() }
    }

    fileprivate func finish(with error: Error?) {
        finishHandler?(error)
        finishHandler = nil
        cancellationHandlers.removeAll()
    }

    /// Synchronizes a conditional execution of a closure.
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

    /// Syncronizes state switching and executes a closure if the action is allowed.
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

// MARK: - CustomDebugStringConvertible, Equatable

extension AsyncTask: CustomDebugStringConvertible, Equatable {
    var debugDescription: String {
        "\(type(of: self)) <\(id.uuidString)>"
    }

    static func == (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - AsyncChain

final class AsyncChain: AsyncTask {
    typealias AsyncTaskProvider = () -> AsyncTask

    private var chain = LinkedList<AsyncTaskProvider>()
    private var completionQueue: DispatchQueue = .main
    private var completion: ((State) -> Void)?

    init(_ taskClosure: @escaping AsyncTaskProvider) {
        chain.append(taskClosure)
        super.init { task in
            Self.performChain(rootTask: task as! AsyncChain)
        }
    }

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

    /// Adds another task to the chain of tasks that will be performed one after another.
    ///
    /// The chain execution breaks with any task completing with error (or starting off with a non-ready state).
    /// You can also cancel the chain by cancelling the root task (the one you're adding tasks to).
    func then(_ taskClosure: @escaping AsyncTaskProvider) -> AsyncChain {
        ifStateIs([.ready, .executing]) { chain.append(taskClosure) }
        return self
    }

    /// Sets the closure that will handle the completion of the chain.
    func handle(on completionQueue: DispatchQueue = .main, completion: @escaping (State) -> Void) -> AsyncTask {
        ifStateIs([.ready, .executing]) {
            self.completionQueue = completionQueue
            self.completion = completion
        }
        return self
    }

    override fileprivate func finish(with error: Error?) {
        super.finish(with: error)
        completionQueue.async { [self] in
            completion?(state)
            completion = nil
        }
        chain.removeAll()
    }
}

// MARK: - AsyncGroup

final class AsyncGroup: AsyncTask {
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

    /// Runs a group of tasks and collects each task's error until `shouldCancelOnError` closure returns `true`.
    ///
    /// `throttle` parameter adds a delay between each task's start by a specified the number of seconds.
    init(
        _ tasks: [AsyncTask],
        shouldCancelOnError: CancellationCondition = .never,
        throttle: TimeInterval = 0,
        completionQueue: DispatchQueue = .main,
        completion: (([Error]) -> Void)? = nil
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

            for (index, task) in tasks.enumerated() {
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
                                shouldCancelOnError.check(error)
                            else { return }

                            abortingError = error
                            onCancel()
                        }
                    }
                }
                task.perform(on: groupTask.queue, delay: TimeInterval(index) * throttle)
            }

            group.notify(queue: completionQueue) {
                completion?(errors)
                groupTask.done(error: abortingError)
            }
        }
    }
}
