//
//  PortfolioFlow.swift
//  T-Stocks
//
//  Created by sleepcha on 9/9/24.
//

import UIKit

final class PortfolioFlow: StackFlowCoordinator {
    weak var navigator: UINavigationController?
    var onStopFlow: VoidHandler?

    private let authService: AuthService
    private let error: Error?
    private let onFinishLoading: VoidHandler
    private let tabBarItem = UITabBarItem(
        title: String(localized: "PortfolioScreenViewController.title", defaultValue: "Портфель"),
        image: UIImage(systemName: "case"),
        selectedImage: UIImage(systemName: "case.fill")
    )

    init(authService: AuthService, showing error: Error? = nil, onFinishLoading: @escaping VoidHandler) {
        self.authService = authService
        self.error = error
        self.onFinishLoading = onFinishLoading
    }

    func start() {
        navigator?.tabBarItem = tabBarItem
        pushPortfolioScreen()
    }

    private func pushPortfolioScreen() {
        guard let networkManager = authService.networkManager else { return }

        let portfolioService = PortfolioServiceImpl(
            accounts: authService.accounts,
            portfolioDataRepository: PortfolioDataRepositoryImpl(networkManager: networkManager),
            assetRepository: AssetRepositoryImpl(networkManager: networkManager),
            closePricesRepo: ClosePricesRepositoryImpl(networkManager: networkManager)
        )
        let logoRepo = LogoRepositoryImpl(logoSize: .x160)
        let timerManager = TimerManagerImpl()

        let portfolioScreen = PortfolioScreenAssemblyImpl().build(
            authService: authService,
            portfolioService: portfolioService,
            logoRepository: logoRepo,
            timerManager: timerManager
        ) { [self] in
            switch $0 {
            case .finishedLoading:
                onFinishLoading()
            case .selectedAsset(let assetID):
                pushAssetScreen(assetID: assetID)
            case .logout:
                stopFlow()
            }
        }

        push(module: portfolioScreen)
    }

    private func pushAssetScreen(assetID: String) {
        // TODO: - push AssetDetailsScreen
        print(assetID)
    }
}
