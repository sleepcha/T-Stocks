//
//  Coordinator.swift
//  T-Stocks
//
//  Created by sleepcha on 9/2/24.
//

import UIKit

// MARK: - Coordinator

protocol Coordinator: AnyObject {
    func start()
    var onStopFlow: VoidHandler? { get set }
}

extension Coordinator {
    func stopFlow() {
        onStopFlow?()
        onStopFlow = nil
    }
}
