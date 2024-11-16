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

    private var currentFlow: BaseCoordinator? {
        didSet {
            currentFlow?.onStopFlow { [weak self] in
                DispatchQueue.mainSync { self?.window.rootViewController = nil }
                self?.currentFlow = nil
            }
        }
    }

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
        currentFlow = tabFlow
    }

    func present(_ stackFlow: StackFlowCoordinator) {
        let navigationController = UINavigationController()
        stackFlow.navigator = navigationController
        stackFlow.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        currentFlow = stackFlow
    }
}
