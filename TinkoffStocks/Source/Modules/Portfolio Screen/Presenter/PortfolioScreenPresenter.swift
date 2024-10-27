//
//  PortfolioScreenPresenter.swift
//  T-Stocks
//
//  Created by sleepcha on 9/17/24.
//

import UIKit

protocol PortfolioScreenPresenter {
    func viewReady()
    func viewAppearing()
    func viewDisappearing()
    func didTapRefreshButton()
    func didSelectItem(withID id: String)
    func willShowLogoForItem(withID id: String, handler: @escaping Handler<UIImage?>)
    func logoutMenuItemTapped()
}
