//
//  Result+Extension.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/14/24.
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
