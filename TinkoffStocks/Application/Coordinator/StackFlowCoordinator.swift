//
//  StackFlowCoordinator.swift
//  T-Stocks
//
//  Created by sleepcha on 9/20/24.
//

import UIKit

// MARK: - StackFlowCoordinator

protocol StackFlowCoordinator: Coordinator {
    var navigator: UINavigationController? { get set }
}

extension StackFlowCoordinator {
    func push(module viewController: UIViewController) {
        navigator?.pushViewController(viewController, animated: navigator?.topViewController != nil)
    }

    func push(flow: StackFlowCoordinator) {
        let topVC = navigator?.topViewController
        flow.navigator = navigator

        let oldHandler = flow.onStopFlow
        flow.onStopFlow = { [weak navigator] in
            oldHandler?()
            guard let topVC else { return }
            navigator?.popToViewController(topVC, animated: true)
        }
        flow.start()
    }

    func present(flow: StackFlowCoordinator, style: UIModalPresentationStyle = .automatic) {
        let newNavigator = UINavigationController()
        flow.navigator = newNavigator

        let oldHandler = flow.onStopFlow
        flow.onStopFlow = { [weak newNavigator] in
            oldHandler?()
            newNavigator?.dismiss(animated: true)
        }

        flow.start()
        navigator?.modalPresentationStyle = style
        navigator?.present(newNavigator, animated: true)
    }

    func popToRoot() {
        navigator?.popToRootViewController(animated: true)
    }
}
