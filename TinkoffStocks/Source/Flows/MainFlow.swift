//
//  MainFlow.swift
//  T-Stocks
//
//  Created by sleepcha on 9/2/24.
//

import UIKit

final class MainFlow: NSObject, TabFlowCoordinator, UITabBarControllerDelegate {
    lazy var tabBarController: UITabBarController = UITabBarController {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        $0.tabBar.standardAppearance = appearance
        $0.tabBar.scrollEdgeAppearance = appearance
        $0.tabBar.tintColor = .tabBarIcon
        $0.delegate = self
    }

    var onStopFlow: VoidHandler?

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func start() {
        let portfolioFlow = PortfolioFlow(authService: authService)
        portfolioFlow.onStopFlow = { [weak self] in self?.stopFlow() }
        startFlows(portfolioFlow)
    }
}
