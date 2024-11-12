//
//  TabFlowCoordinator.swift
//  T-Stocks
//
//  Created by sleepcha on 9/20/24.
//

import UIKit

// MARK: - TabFlowCoordinator

class TabFlowCoordinator: BaseCoordinator {
    weak var tabBarController: UITabBarController?
}

extension TabFlowCoordinator {
    func present(_ flows: StackFlowCoordinator...) {
        guard let tabBarController else { return }

        let navigators = flows.map { flow in
            let navigator = UINavigationController()
            flow.navigator = navigator
            return navigator
        }
        tabBarController.setViewControllers(navigators, animated: false)
        flows.forEach { $0.start() }
    }
}
