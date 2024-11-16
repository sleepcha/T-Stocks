//
//  AppCoordinator.swift
//  T-Stocks
//
//  Created by sleepcha on 11/2/24.
//

import UIKit

// MARK: - AppCoordinator

class AppCoordinator: NSObject, Coordinator {
    var window: UIWindow
    private var currentFlow: Coordinator?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {}
}

extension AppCoordinator {
    func present(_ tabFlow: TabFlowCoordinator) {
        let tabBarController = UITabBarController()
        tabFlow.tabBarController = tabBarController
        tabFlow.start()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        // retain the child flow until it's finished
        currentFlow = tabFlow
        tabFlow.onStopFlow { [weak self] in
            self?.window.rootViewController = nil
            self?.currentFlow = nil
        }
    }

    func present(_ stackFlow: StackFlowCoordinator) {
        let navigationController = UINavigationController()
        stackFlow.navigator = navigationController
        stackFlow.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        // retain the child flow until it's finished
        currentFlow = stackFlow
        stackFlow.onStopFlow { [weak self] in
            self?.window.rootViewController = nil
            self?.currentFlow = nil
        }
    }
}
