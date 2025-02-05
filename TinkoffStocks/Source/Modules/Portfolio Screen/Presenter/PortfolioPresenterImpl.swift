//
//  PortfolioPresenterImpl.swift
//  T-Stocks
//
//  Created by sleepcha on 21.09.2024.
//

import Foundation
import UIKit

// MARK: - PortfolioScreenOutput

enum PortfolioScreenOutput {
    case selectedAsset(asset: Asset)
    case logout
}

// MARK: - PortfolioPresenterImpl

final class PortfolioPresenterImpl {
    typealias AccountCellModelMapper = (Portfolio, GainPeriod) -> AccountCellModel
    typealias PortfolioItemCellModelMapper = (Portfolio.Item, GainPeriod) -> PortfolioItemCellModel
    typealias PortfolioSummaryMapper = (Portfolio, GainPeriod) -> PortfolioSummary

    // MARK: Dependencies

    private let view: PortfolioView
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
        portfolioView: PortfolioView,
        accountSliderView: AccountSliderView,
        authService: AuthService,
        portfolioService: PortfolioService,
        logoRepository: LogoRepository,
        timerManager: TimerManager,
        outputHandler: @escaping Handler<PortfolioScreenOutput>,
        accountCellMapper: @escaping AccountCellModelMapper = PortfolioFormatters.mapToAccountCellModel,
        portfolioItemCellMapper: @escaping PortfolioItemCellModelMapper = PortfolioFormatters.mapToPortfolioItemCellModel,
        summaryMapper: @escaping PortfolioSummaryMapper = PortfolioFormatters.mapToPortfolioSummary
    ) {
        self.view = portfolioView
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

// MARK: - PortfolioPresenter

extension PortfolioPresenterImpl: PortfolioPresenter {
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
        guard let asset = portfolios[currentAccountIndex].items[id]?.asset else { return }
        outputHandler(.selectedAsset(asset: asset))
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

extension PortfolioPresenterImpl: AccountSliderPresenter {
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
                sortedBy: \.orderID,
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
        case .share: String(localized: "PortfolioPresenter.sections.shares", defaultValue: "Акции")
        case .bond: String(localized: "PortfolioPresenter.sections.bonds", defaultValue: "Облигации")
        case .etf: String(localized: "PortfolioPresenter.sections.etfs", defaultValue: "Фонды")
        case .future: String(localized: "PortfolioPresenter.sections.future", defaultValue: "Фьючерсы")
        case .option: String(localized: "PortfolioPresenter.sections.options", defaultValue: "Опционы")
        case .structuredProduct: String(localized: "PortfolioPresenter.sections.structuredProducts", defaultValue: "Структурные ноты")
        case .other: String(localized: "PortfolioPresenter.sections.other", defaultValue: "Другое")
        case .currency: String(localized: "PortfolioPresenter.sections.currencies", defaultValue: "Валюта и металлы")
        }
    }

    var orderID: Int {
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

// MARK: - Asset.TypeData + Hashable

extension Asset.TypeData: Hashable {
    static func == (lhs: Asset.TypeData, rhs: Asset.TypeData) -> Bool {
        lhs.orderID == rhs.orderID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(orderID)
    }
}

// MARK: - Constants

private extension C {
    enum LogoutDialog {
        static let title = String(localized: "PortfolioPresenter.logoutDialog.title", defaultValue: "Вы действительно хотите выйти?")
        static let text = String(localized: "PortfolioPresenter.logoutDialog.text", defaultValue: "Токен будет удалён с вашего устройства, для входа нужно будет ввести его заново")
        static let logoutButtonTitle = String(localized: "PortfolioPresenter.logoutDialog.logoutButtonTitle", defaultValue: "Выйти")
        static let cancelButtonTitle = String(localized: "PortfolioPresenter.logoutDialog.cancelButtonTitle", defaultValue: "Отмена")
    }

    static let timerInterval: TimeInterval = 10
    static let timerTolerance: TimeInterval = 0.5
}
