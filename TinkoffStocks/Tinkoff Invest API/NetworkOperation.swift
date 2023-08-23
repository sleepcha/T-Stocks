//
//  NetworkOperation.swift
//  TinkoffStocks
//
//  Created by sleepcha on 3/17/23.
//

import Foundation


public class NetworkOperation: AsyncOperation {
    private var _task: URLSessionTask?
    
    /// `finish()` method must be called inside the task's completion handler in order to signal that operation is done.
    var task: URLSessionTask? {
        get {
            return Self.stateQueue.sync { _task }
        }
        set {
            Self.stateQueue.async(flags: .barrier) { self._task = newValue }
        }
    }

    public override func main() {
        guard !isCancelled, let task else {
            finish()
            return
        }
        task.resume()
    }
    
    public override func cancel() {
        task?.cancel()
        task = nil
        super.cancel()
    }
}
