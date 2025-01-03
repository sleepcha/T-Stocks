//
//  PortfolioFlow.swift
//  T-Stocks
//
//  Created by sleepcha on 9/9/24.
//

import SwiftUI
import UIKit

final class PortfolioFlow: StackFlowCoordinator {
    private let networkManager: NetworkManager
    private let authService: AuthService
    private let error: Error?
    private let tabBarItem = UITabBarItem(
        title: String(localized: "PortfolioFlow.tabBarItem.title", defaultValue: "Портфель"),
        image: UIImage(systemName: "case"),
        selectedImage: UIImage(systemName: "case.fill")
    )

    init(networkManager: NetworkManager, authService: AuthService, showing error: Error? = nil) {
        self.networkManager = networkManager
        self.authService = authService
        self.error = error
    }

    override func start() {
        navigator?.tabBarItem = tabBarItem
        pushPortfolioScreen()
    }

    private func pushPortfolioScreen() {
        let portfolioService = PortfolioServiceImpl(
            accounts: authService.accounts,
            portfolioDataRepository: PortfolioDataRepositoryImpl(networkManager: networkManager),
            assetRepository: AssetRepositoryImpl(networkManager: networkManager),
            closePricesRepository: ClosePricesRepositoryImpl(networkManager: networkManager)
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
            case .selectedAsset(let assetID):
                pushAssetScreen(assetID: assetID)
            case .logout:
                stop()
            }
        }
        push(screen: portfolioScreen)
    }

    private func pushAssetScreen(assetID: AssetID) {
        guard assetID.id != C.ID.rubleAsset else { return }
        print(assetID)

        let assetRepo = AssetRepositoryImpl(networkManager: networkManager)
        let view = AssetDetailsScreenAssemblyImpl().build(assetID: assetID, assetRepository: assetRepo)
        let screen = UIHostingController(rootView: view)
        screen.hidesBottomBarWhenPushed = true

        push(screen: screen)
    }
}
