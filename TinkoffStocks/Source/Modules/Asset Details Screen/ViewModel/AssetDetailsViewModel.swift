//
//  AssetDetailsViewModelState.swift
//  T-Stocks
//
//  Created by sleepcha on 1/14/25.
//

import Combine

// MARK: - AssetDetailsViewModelState

enum AssetDetailsViewModelState {
    case idle
    case showingError(String)
}

// MARK: - AssetDetailsViewModel

protocol AssetDetailsViewModel: ObservableObject {
    associatedtype ChartVM: ChartViewModel

    var selectedInterval: CandleStickInterval { get set }
    var state: AssetDetailsViewModelState { get }
    var title: String { get }
    var subtitle: String { get }
    var currentPrice: String { get }
    var priceChange: PriceChange { get }
    var openPositions: [AssetPositionModel] { get }
    var chartViewModel: ChartVM { get }

    func reload() async
    func buyButtonTapped()
    func sellButtonTapped()
}
