//
//  PortfolioScreenPresenterImpl.swift
//  T-Stocks
//
//  Created by sleepcha on 21.09.2024.
//

import Foundation
import UIKit

// MARK: - PortfolioScreenOutput

enum PortfolioScreenOutput {
    case selectedAsset(assetID: AssetID)
    case logout
}

// MARK: - PortfolioScreenPresenterImpl

final class PortfolioScreenPresenterImpl {
    typealias AccountCellModelMapper = (Portfolio, GainPeriod) -> AccountCellModel
    typealias PortfolioItemCellModelMapper = (Portfolio.Item, GainPeriod) -> PortfolioItemCellModel
    typealias PortfolioSummaryMapper = (Portfolio, GainPeriod) -> PortfolioSummary

    // MARK: Dependencies

    private let view: PortfolioScreenView
    private let accountSliderView: AccountSliderView
    private let authService: AuthService
    private let portfolioService: PortfolioService
    private let logoRepo: LogoRepository
    private let timerManager: TimerManager
    private let accountCellMapper: AccountCellModelMapper
    private let portfolioItemCellMapper: PortfolioItemCellModelMapper
    private let summaryMapper: PortfolioSummaryMapper
    private let outputHandler: Handler<PortfolioScreenOutput>

    // MARK: State

    private var portfolios: [Portfolio] = []
    private var gainPeriod: GainPeriod = .sinceLastClose
    private var currentAccountIndex: Int = 0

    init(
        portfolioScreenView: PortfolioScreenView,
        accountSliderView: AccountSliderView,
        authService: AuthService,
        portfolioService: PortfolioService,
        logoRepository: LogoRepository,
        timerManager: TimerManager,
        outputHandler: @escaping Handler<PortfolioScreenOutput>,
        accountCellMapper: @escaping AccountCellModelMapper = PortfolioFormatter.mapToAccountCellModel,
        portfolioItemCellMapper: @escaping PortfolioItemCellModelMapper = PortfolioItemFormatter.mapToPortfolioItemCellModel,
        summaryMapper: @escaping PortfolioSummaryMapper = PortfolioFormatter.mapToPortfolioSummary
    ) {
        self.view = portfolioScreenView
        self.accountSliderView = accountSliderView
        self.authService = authService
        self.portfolioService = portfolioService
        self.logoRepo = logoRepository
        self.timerManager = timerManager
        self.accountCellMapper = accountCellMapper
        self.portfolioItemCellMapper = portfolioItemCellMapper
        self.summaryMapper = summaryMapper
        self.outputHandler = outputHandler
    }
}

// MARK: - PortfolioScreenPresenter

extension PortfolioScreenPresenterImpl: PortfolioScreenPresenter {
    func viewReady() {
        updatePortfolios()
    }

    func viewAppearing() {
        timerManager.resume()
    }

    func viewDisappearing() {
        timerManager.pause()
    }

    func didTapRefreshButton() {
        updatePortfolios()
    }

    func didSelectItem(withID id: String) {
        guard let assetID = portfolios[currentAccountIndex].items[id]?.asset.assetID else { return }
        outputHandler(.selectedAsset(assetID: assetID))
    }

    func willShowLogoForItem(withID id: String, handler: @escaping Handler<UIImage?>) {
        guard let logoName = portfolios[currentAccountIndex].items[id]?.asset.brand.logoName else { return }

        logoRepo.getLogo(logoName) { handler($0.success) }
    }

    func logoutMenuItemTapped() {
        let logoutDialog = Dialog(
            title: C.LogoutDialog.title,
            text: C.LogoutDialog.text,
            actions: [
                Dialog.Action(title: C.LogoutDialog.logoutButtonTitle, kind: .destructive, handler: { self.outputHandler(.logout) }),
                Dialog.Action(title: C.LogoutDialog.cancelButtonTitle, kind: .cancel, handler: {}),
            ]
        )
        view.showDialog(dialog: logoutDialog)
    }

    private func startTimer(interval: TimeInterval = C.timerInterval) {
        timerManager.schedule(
            timeInterval: interval,
            tolerance: C.timerTolerance,
            repeats: false,
            action: { [weak self] in self?.updatePortfolios() }
        )
    }

    private func updatePortfolios() {
        portfolioService.getAllPortfolios { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let error):
                switch error {
                case .networkError, .serverError, .taskCancelled:
                    view.showErrorMessage(message: error.localizedDescription)
                case .unauthorized:
                    outputHandler(.logout)
                case .tooManyRequests(let seconds):
                    if portfolios.isEmpty {
                        view.showErrorMessage(message: error.localizedDescription)
                    }
                    startTimer(interval: seconds)
                }
            case .success(let newPortfolios):
                guard newPortfolios.count >= portfolios.count else { return }
                portfolios = newPortfolios
                updateAccountSlider()
                startTimer()
            }
        }
    }

    private func updateAccountSlider() {
        let cellModels = portfolios.map { accountCellMapper($0, gainPeriod) }
        accountSliderView.updateAccountList(cellModels)
    }
}

// MARK: - AccountSliderPresenter

extension PortfolioScreenPresenterImpl: AccountSliderPresenter {
    func didTapGainPeriodButton() {
        gainPeriod.toggle()
        updateAccountSlider()
    }

    func didSelectAccount(withID id: String) {
        currentAccountIndex = portfolios.firstIndex { $0.account.id == id } ?? 0
        updatePortfolioItemList()
    }

    private func updatePortfolioItemList() {
        let accountIndex = (currentAccountIndex < portfolios.count)
            ? currentAccountIndex
            : portfolios.count - 1

        guard accountIndex >= 0 else {
            view.updateItemList(with: DataSource(sections: []), portfolioSummary: PortfolioSummary("", NSAttributedString()))
            return
        }

        let portfolio = portfolios[accountIndex]

        let dataSource = portfolio.items.values
            .grouped(
                by: \.asset.typeData,
                sortedBy: \.order,
                elementsSortedBy: \.asset.name
            )
            .map {
                DataSource.Section(
                    header: $0.group.name,
                    items: $0.elements.map { portfolioItemCellMapper($0, gainPeriod) }
                )
            }
            .apply(DataSource.init)

        view.updateItemList(with: dataSource, portfolioSummary: summaryMapper(portfolio, gainPeriod))
    }
}

// MARK: - Helpers

extension Asset.TypeData {
    var name: String {
        switch self {
        case .share: String(localized: "PortfolioScreenPresenter.sections.shares", defaultValue: "Акции")
        case .bond: String(localized: "PortfolioScreenPresenter.sections.bonds", defaultValue: "Облигации")
        case .etf: String(localized: "PortfolioScreenPresenter.sections.etfs", defaultValue: "Фонды")
        case .future: String(localized: "PortfolioScreenPresenter.sections.future", defaultValue: "Фьючерсы")
        case .option: String(localized: "PortfolioScreenPresenter.sections.options", defaultValue: "Опционы")
        case .structuredProduct: String(localized: "PortfolioScreenPresenter.sections.structuredProducts", defaultValue: "Структурные ноты")
        case .other: String(localized: "PortfolioScreenPresenter.sections.other", defaultValue: "Другое")
        case .currency: String(localized: "PortfolioScreenPresenter.sections.currencies", defaultValue: "Валюта и металлы")
        }
    }

    var order: Int {
        switch self {
        case .share: 1
        case .bond: 2
        case .etf: 3
        case .future: 4
        case .option: 5
        case .structuredProduct: 6
        case .other: .max - 1
        case .currency: .max
        }
    }
}

// MARK: - Constants

private extension C {
    enum LogoutDialog {
        static let title = String(localized: "PortfolioScreenPresenter.logoutDialog.title", defaultValue: "Вы действительно хотите выйти?")
        static let text = String(localized: "PortfolioScreenPresenter.logoutDialog.text", defaultValue: "Токен будет удалён с вашего устройства, для входа нужно будет ввести его заново")
        static let logoutButtonTitle = String(localized: "PortfolioScreenPresenter.logoutDialog.logoutButtonTitle", defaultValue: "Выйти")
        static let cancelButtonTitle = String(localized: "PortfolioScreenPresenter.logoutDialog.cancelButtonTitle", defaultValue: "Отмена")
    }

    static let timerInterval: TimeInterval = 10
    static let timerTolerance: TimeInterval = 0.5
}
