//
//  PortfolioScreenAssembly.swift
//  T-Stocks
//
//  Created by sleepcha on 8/14/24.
//

import UIKit

// MARK: - PortfolioScreenAssembly

protocol PortfolioScreenAssembly {
    func build(
        authService: AuthService,
        portfolioService: PortfolioService,
        logoRepository: LogoRepository,
        timerManager: TimerManager,
        outputHandler: @escaping Handler<PortfolioScreenOutput>
    ) -> UIViewController
}

// MARK: - PortfolioScreenAssemblyImpl

final class PortfolioScreenAssemblyImpl: PortfolioScreenAssembly {
    func build(
        authService: AuthService,
        portfolioService: PortfolioService,
        logoRepository: LogoRepository,
        timerManager: TimerManager,
        outputHandler: @escaping Handler<PortfolioScreenOutput>
    ) -> UIViewController {
        let portfolioScreen = PortfolioScreenVC()
        let accountSlider = AccountSliderVC()
        let presenter = PortfolioScreenPresenterImpl(
            portfolioScreenView: WeakRefMainQueueProxy(portfolioScreen),
            accountSliderView: WeakRefMainQueueProxy(accountSlider),
            authService: authService,
            portfolioService: portfolioService,
            logoRepository: logoRepository,
            timerManager: timerManager,
            outputHandler: outputHandler
        )

        portfolioScreen.addChild(accountSlider)
        portfolioScreen.presenter = presenter
        accountSlider.presenter = presenter

        return portfolioScreen
    }
}

// MARK: - WeakRefMainQueueProxy + PortfolioScreenView

extension WeakRefMainQueueProxy: PortfolioScreenView where Subject: PortfolioScreenView {
    func updateItemList(with newDataSource: DataSource<PortfolioItemCellModel>, portfolioSummary: PortfolioSummary) {
        dispatch { $0.updateItemList(with: newDataSource, portfolioSummary: portfolioSummary) }
    }

    func showDialog(dialog: Dialog) {
        dispatch { $0.showDialog(dialog: dialog) }
    }

    func showErrorMessage(message: String) {
        dispatch { $0.showErrorMessage(message: message) }
    }
}

// MARK: - WeakRefMainQueueProxy + PortfolioScreenView

extension WeakRefMainQueueProxy: AccountSliderView where Subject: AccountSliderView {
    func updateAccountList(_ newDataSource: [AccountCellModel]) {
        dispatch { $0.updateAccountList(newDataSource) }
    }
}
