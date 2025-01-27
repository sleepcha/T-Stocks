//
//  MainFlow.swift
//  T-Stocks
//
//  Created by sleepcha on 9/2/24.
//

import UIKit

final class MainFlow: TabFlowCoordinator, UITabBarControllerDelegate {
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    override func start() {
        guard let tabBarController, let networkManager = authService.networkManager else { return }

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = .tabBarIcon
        tabBarController.delegate = self

        let portfolioFlow = PortfolioFlow(networkManager: networkManager, authService: authService)
        portfolioFlow.onStopFlow { [weak self] in self?.stop() }
        present(portfolioFlow)
    }
}
