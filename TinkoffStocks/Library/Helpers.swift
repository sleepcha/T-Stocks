//
//  Helpers.swift
//  TinkoffStocks
//
//  Created by sleepcha on 8/23/23.
//

import Foundation

typealias ResultHandler<T> = (Result<T, Error>) -> Void

extension Result {
    var failure: Failure? {
        switch self {
        case let .failure(failure): failure
        default: nil
        }
    }

    var success: Success? {
        switch self {
        case let .success(success): success
        default: nil
        }
    }
}

extension Collection {
    func apply<T>(_ transform: (Self) -> T) -> T {
        transform(self)
    }
}

extension DispatchQueue {
    /// Safer version of `.main.sync` that prevents a potential deadlock.
    @discardableResult
    class func mainSync<T>(closure: () throws -> T) rethrows -> T {
        try Thread.isMainThread ? closure() : DispatchQueue.main.sync { try closure() }
    }
}
