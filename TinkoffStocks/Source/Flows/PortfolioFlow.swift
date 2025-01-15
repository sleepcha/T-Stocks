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
    private let portfolioDataRepo: PortfolioDataRepository
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
        self.portfolioDataRepo = PortfolioDataRepositoryImpl(accounts: authService.accounts, networkManager: networkManager)
    }

    override func start() {
        navigator?.tabBarItem = tabBarItem
        pushPortfolioScreen()
    }

    private func pushPortfolioScreen() {
        let portfolioService = PortfolioServiceImpl(
            accounts: authService.accounts,
            portfolioDataRepository: portfolioDataRepo,
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
            case .selectedAsset(let asset):
                pushAssetScreen(asset: asset)
            case .logout:
                stop()
            }
        }
        push(screen: portfolioScreen)
    }

    private func pushAssetScreen(asset: Asset) {
        guard asset.id != C.ID.rubleAsset else { return }

        let candlesRepo = CandlesRepositoryImpl(networkManager: networkManager)

        let assetDetailsScreen = AssetDetailsScreenAssemblyImpl().build(
            asset: asset,
            candlesRepository: candlesRepo,
            portfolioDataRepository: portfolioDataRepo
        ) {
            _ = self // retain coordinator

            switch $0 {
            case .buy(let asset):
                print("push buy screen for asset: \(asset)")
            case .sell(let asset):
                print("push sell screen for asset: \(asset)")
            }
        }

        navigator?.navigationBar.tintColor = UIColor(hex: asset.brand.textColor)
        push(screen: assetDetailsScreen)
    }
}
