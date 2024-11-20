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
        let portfolioVC = PortfolioViewController()
        let accountSliderVC = AccountSliderViewController()
        let presenter = PortfolioPresenterImpl(
            portfolioView: WeakRefMainQueueProxy(portfolioVC),
            accountSliderView: WeakRefMainQueueProxy(accountSliderVC),
            authService: authService,
            portfolioService: portfolioService,
            logoRepository: logoRepository,
            timerManager: timerManager,
            outputHandler: outputHandler
        )

        portfolioVC.addChild(accountSliderVC)
        portfolioVC.presenter = presenter
        accountSliderVC.presenter = presenter

        return portfolioVC
    }
}

// MARK: - WeakRefMainQueueProxy + PortfolioView

extension WeakRefMainQueueProxy: PortfolioView where Subject: PortfolioView {
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

// MARK: - WeakRefMainQueueProxy + AccountSliderView

extension WeakRefMainQueueProxy: AccountSliderView where Subject: AccountSliderView {
    func updateAccountList(_ newDataSource: [AccountCellModel]) {
        dispatch { $0.updateAccountList(newDataSource) }
    }
}
