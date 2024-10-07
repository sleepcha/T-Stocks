//
//  TabFlowCoordinator.swift
//  T-Stocks
//
//  Created by sleepcha on 9/20/24.
//

import UIKit

// MARK: - TabFlowCoordinator

protocol TabFlowCoordinator: Coordinator {
    var tabBarController: UITabBarController { get set }
    func startFlows(_ flows: StackFlowCoordinator...)
}

extension TabFlowCoordinator {
    func startFlows(_ flows: StackFlowCoordinator...) {
        let navigators = flows.map { flow in
            let navigator = UINavigationController()
            flow.navigator = navigator
            return navigator
        }
        tabBarController.setViewControllers(navigators, animated: false)
        flows.forEach { $0.start() }
    }
}
