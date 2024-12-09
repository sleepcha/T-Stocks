//
//  StackFlowCoordinator.swift
//  T-Stocks
//
//  Created by sleepcha on 9/20/24.
//

import UIKit

// MARK: - StackFlowCoordinator

class StackFlowCoordinator: BaseCoordinator {
    weak var navigator: UINavigationController? {
        didSet { flowRootIndex = nil }
    }

    // store the first screen's stack index to be able to popToRoot later
    private var flowRootIndex: Int?
}

extension StackFlowCoordinator {
    func push(screen: UIViewController) {
        guard let parentNavigator = navigator?.topPresentedNavigator else { return }

        flowRootIndex = flowRootIndex ?? parentNavigator.viewControllers.count
        let isFirstScreen = parentNavigator.viewControllers.isEmpty
        parentNavigator.pushViewController(screen, animated: !isFirstScreen)
    }

    func present(
        screen: UIViewController,
        style: UIModalPresentationStyle = .automatic,
        isModalInPresentation: Bool = false
    ) {
        guard let parentNavigator = navigator?.topPresentedNavigator else { return }

        flowRootIndex = flowRootIndex ?? 0
        let newNavigator = screen as? UINavigationController ?? UINavigationController(rootViewController: screen)
        newNavigator.modalPresentationStyle = style
        newNavigator.isModalInPresentation = isModalInPresentation
        parentNavigator.present(newNavigator, animated: true)
    }

    func push(flow: StackFlowCoordinator) {
        guard let parentNavigator = navigator?.topPresentedNavigator else { return }

        let parentVC = parentNavigator.topViewController
        flow.navigator = parentNavigator

        flow.onStopFlow { [weak parentNavigator, weak parentVC] in
            guard let parentVC, let parentNavigator else { return }

            // if by the time the flow stops there are some modal screens — dismiss them
            parentNavigator.dismissPresented()
            parentNavigator.popToViewController(parentVC, animated: true)
        }
        flow.start()
    }

    func present(
        flow: StackFlowCoordinator,
        style: UIModalPresentationStyle = .automatic,
        isModalInPresentation: Bool = false
    ) {
        guard let parentNavigator = navigator?.topPresentedNavigator else { return }

        let newNavigator = UINavigationController {
            $0.modalPresentationStyle = style
            $0.isModalInPresentation = isModalInPresentation
        }

        flow.navigator = newNavigator
        flow.onStopFlow { [weak parentNavigator] in
            parentNavigator?.dismiss(animated: true)
        }
        flow.start()

        parentNavigator.present(newNavigator, animated: true)
    }

    func popToRoot() {
        guard let navigator, let flowRootIndex else { return }
        navigator.dismissPresented()
        navigator.popToViewControllerAt(flowRootIndex)
    }
}

// MARK: - Helpers

private extension UINavigationController {
    var topPresentedNavigator: UINavigationController {
        var current = self
        while let child = current.presentedViewController as? UINavigationController {
            current = child
        }
        return current
    }

    func popToViewControllerAt(_ index: Int) {
        guard let vc = viewControllers[safe: index] else { return }
        popToViewController(vc, animated: true)
    }
}

private extension UIViewController {
    func dismissPresented() {
        if presentedViewController != nil { dismiss(animated: true) }
    }
}
