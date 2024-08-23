//
//  WeakRefMainQueueProxy.swift
//  T-Stocks
//
//  Created by sleepcha on 8/22/24.
//

import Foundation

/// Extend to conform to your View protocol by wrapping each method call in `dispatch(_:)`.
final class WeakRefMainQueueProxy<View: AnyObject> {
    private weak var view: View?

    init(_ view: View) {
        self.view = view
    }

    func dispatch(_ completion: @escaping (View) -> Void) {
        guard let view else { return }
        DispatchQueue.mainAsync { completion(view) }
    }
}
