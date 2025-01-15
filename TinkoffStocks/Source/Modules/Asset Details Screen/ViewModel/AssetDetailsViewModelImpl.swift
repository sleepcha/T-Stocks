//
//  AssetDetailsViewModelImpl.swift
//  T-Stocks
//
//  Created by sleepcha on 11/20/24.
//

import SwiftUI

// MARK: - AssetDetailsScreenOutput

enum AssetDetailsScreenOutput {
    case buy(Asset)
    case sell(Asset)
}

// MARK: - AssetDetailsViewModelImpl

final class AssetDetailsViewModelImpl<ChartVM: ChartViewModel>: AssetDetailsViewModel, ObservableObject {
    typealias AssetPositionModelMapper = (PortfolioData.OpenPosition, Asset, String) -> AssetPositionModel
    typealias CandleStickModelFormatter = (CandleStickModel, Asset) -> (price: String, gain: String)

    @Published var selectedInterval: CandleStickInterval = .hour1
    @Published private(set) var openPositions = [AssetPositionModel]()
    @Published private(set) var state: AssetDetailsViewModelState = .idle
    @Published private(set) var title: String
    @Published private(set) var subtitle: String
    @Published private(set) var currentPrice: String = " "
    @Published private(set) var gainState: GainState = .neutral
    @Published private(set) var gainString: String = " "
    @Published private(set) var chartViewModel: ChartVM

    private let asset: Asset
    private let candlesRepo: CandlesRepository
    private let portfolioDataRepo: PortfolioDataRepository
    private let outputHandler: Handler<AssetDetailsScreenOutput>
    private let mapToAssetPositionModel: AssetPositionModelMapper
    private let formatCandleStickModel: CandleStickModelFormatter

    init(
        chartViewModel: ChartVM,
        asset: Asset,
        candlesRepository: CandlesRepository,
        portfolioDataRepository: PortfolioDataRepository,
        outputHandler: @escaping Handler<AssetDetailsScreenOutput>,
        assetPositionModelMapper: @escaping AssetPositionModelMapper = PortfolioItemFormatter.mapToAssetPositionModel,
        candleStickModelFormatter: @escaping CandleStickModelFormatter = PortfolioItemFormatter.formatCandleStickModel
    ) {
        self.chartViewModel = chartViewModel
        self.asset = asset
        self.title = asset.name
        self.subtitle = asset.ticker
        self.candlesRepo = candlesRepository
        self.portfolioDataRepo = portfolioDataRepository
        self.outputHandler = outputHandler
        self.mapToAssetPositionModel = assetPositionModelMapper
        self.formatCandleStickModel = candleStickModelFormatter
    }

    func reload() async {
        let interval = selectedInterval

        do {
            async let candlesRes = candlesRepo
                .getCandles(asset.id, interval: interval, limit: C.candleCountLimit)
                .map { CandleStickModel(from: $0, interval: interval) }

            async let portfoliosDataRes = portfolioDataRepo
                .getAllPortfoliosData()
                .compactMap { portfolio in
                    portfolio.openPositions.first { $0.instrumentID == asset.id }.map {
                        mapToAssetPositionModel($0, asset, portfolio.name)
                    }
                }

            let (candles, portfoliosData) = try await (candlesRes, portfoliosDataRes)

            await MainActor.run {
                defer { state = .idle }
                guard let lastCandle = candles.last else { return }
                print(lastCandle.close)
                (currentPrice, gainString) = formatCandleStickModel(lastCandle, asset)
                gainState = lastCandle.gainState
                chartViewModel.candles = candles
                openPositions = portfoliosData
            }
        } catch {
            await MainActor.run {
                state = .showingError(error.localizedDescription)
            }
        }
    }

    func buyButtonTapped() {
        outputHandler(.buy(asset))
    }

    func sellButtonTapped() {
        outputHandler(.sell(asset))
    }
}

// MARK: - Constants

private extension C {
    static let candleCountLimit: Int = 60
}
