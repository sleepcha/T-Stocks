//
//  PortfolioView.swift
//  T-Stocks
//
//  Created by sleepcha on 8/14/24.
//

import Foundation

typealias PortfolioSummary = (total: String, gain: NSAttributedString)

// MARK: - PortfolioView

protocol PortfolioView {
    func updateItemList(with newDataSource: DataSource<PortfolioItemCellModel>, portfolioSummary: PortfolioSummary)
    func showErrorMessage(message: String)
    func showDialog(dialog: Dialog)
}
