//
//  AsyncOperation.swift
//  TinkoffStocks
//
//  Created by sleepcha on 3/14/23.
//

import Foundation


public class AsyncOperation: Operation {
    @objc enum State: Int {
        case ready
        case executing
        case finished
    }
    
    static let stateQueue = DispatchQueue(label: "AsyncOperation.ReaderWriterQueue", qos: .userInteractive, attributes: .concurrent)
    
    private var _state = State.ready
    @objc private dynamic var state: State {
        get {
            Self.stateQueue.sync { _state }
        }
        set {
            Self.stateQueue.sync(flags: .barrier) { self._state = newValue }
        }
    }
    
    /// `finish()` method must be called inside the block in order to signal that operation is done.
    var mainBlock: (() -> Void)?
    
    public final func finish() {
        if !isFinished { state = .finished }
    }

    public override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isExecuting", "isFinished"].contains(key) {
            return [#keyPath(state)]
        }
        
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    public override var isExecuting: Bool { return state == .executing }
    
    public override var isFinished: Bool {get { return state == .finished } set{}}
    
    public override var isAsynchronous: Bool { return true }
    
    public override var isReady: Bool { return super.isReady && state == .ready }

    public override func start() {
        if isCancelled {
            finish()
            return
        }
        
        state = .executing
        main()
    }
    
    public override func main() {
        guard !isCancelled, let mainBlock else {
            finish()
            return
        }
        mainBlock()
    }

    public override func cancel() {
        finish()
        super.cancel()
    }
}
