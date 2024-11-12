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
    }

    func present(_ stackFlow: StackFlowCoordinator) {
        let navigationController = UINavigationController()
        stackFlow.navigator = navigationController
        stackFlow.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
