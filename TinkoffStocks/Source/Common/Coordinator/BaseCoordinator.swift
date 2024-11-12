//
//  BaseCoordinator.swift
//  T-Stocks
//
//  Created by sleepcha on 11/8/24.
//

import Foundation

class BaseCoordinator: NSObject, Coordinator {
    private var onStopFlowHandlers: [VoidHandler] = []

    func start() {}

    func stop() {
        onStopFlowHandlers.reversed().forEach { $0() }
        onStopFlowHandlers.removeAll()
    }

    func onStopFlow(_ handler: @escaping VoidHandler) {
        onStopFlowHandlers.append(handler)
    }
}
