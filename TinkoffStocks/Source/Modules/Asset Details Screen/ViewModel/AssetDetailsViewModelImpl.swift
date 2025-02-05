//
//  AssetDetailsViewModelImpl.swift
//  T-Stocks
//
//  Created by sleepcha on 11/20/24.
//

import Combine
import Foundation

// MARK: - AssetDetailsScreenOutput

enum AssetDetailsScreenOutput {
    case buy(Asset)
    case sell(Asset)
}

// MARK: - AssetDetailsViewModelImpl

final class AssetDetailsViewModelImpl<ChartVM: ChartViewModel>: AssetDetailsViewModel, ObservableObject {
    typealias AssetPositionModelMapper = (PortfolioData.OpenPosition, Asset, String) -> AssetPositionModel
    typealias PriceFormatter = (Decimal, Asset) -> String

    @Published var selectedInterval: CandleStickInterval = .hour1
    @Published private(set) var state: AssetDetailsViewModelState = .idle

    private(set) var openPositions = [AssetPositionModel]()
    private(set) var currentPrice: String = " "
    private(set) var priceChange: PriceChange = .zero
    private(set) var chartViewModel: ChartVM

    var title: String { asset.name }
    var subtitle: String { asset.ticker }

    private let asset: Asset
    private let candlesRepo: CandlesRepository
    private let portfolioDataRepo: PortfolioDataRepository
    private let outputHandler: Handler<AssetDetailsScreenOutput>
    private let mapToAssetPositionModel: AssetPositionModelMapper
    private let formatPrice: PriceFormatter
    private var cancellables = Set<AnyCancellable>()

    init(
        chartViewModel: ChartVM,
        asset: Asset,
        candlesRepository: CandlesRepository,
        portfolioDataRepository: PortfolioDataRepository,
        assetPositionModelMapper: @escaping AssetPositionModelMapper = PortfolioFormatters.mapToAssetPositionModel,
        priceFormatter: @escaping PriceFormatter = PortfolioFormatters.formatPrice,
        outputHandler: @escaping Handler<AssetDetailsScreenOutput>
    ) {
        self.chartViewModel = chartViewModel
        self.asset = asset
        self.candlesRepo = candlesRepository
        self.portfolioDataRepo = portfolioDataRepository
        self.outputHandler = outputHandler
        self.mapToAssetPositionModel = assetPositionModelMapper
        self.formatPrice = priceFormatter
        $selectedInterval
            .removeDuplicates() // Prevent duplicate calls for the same value
            .sink { [weak self] _ in
                Task { await self?.reload() }
            }
            .store(in: &cancellables)
    }

    @MainActor
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

            defer { state = .idle }
            guard let lastCandle = candles.last else { return }

            currentPrice = formatPrice(lastCandle.close, asset)
            priceChange = lastCandle.priceChange(asset: asset)
            chartViewModel.update(with: candles)
            openPositions = portfoliosData
        } catch {
            state = .showingError(error.localizedDescription)
        }
    }

    func buyButtonTapped() {
        outputHandler(.buy(asset))
    }

    func sellButtonTapped() {
        outputHandler(.sell(asset))
    }
}

// MARK: - Helpers

extension CandleStickModel {
    func priceChange(asset: Asset? = nil) -> PriceChange {
        guard let asset else { return PriceChange(from: open, to: close) }

        return PriceChange(
            from: open,
            to: close,
            fractionLength: asset.fractionLength,
            unit: asset.isFuture ? .futurePoints : .currency(asset.currency.isoCode)
        )
    }
}

// MARK: - Constants

private extension C {
    static let candleCountLimit: Int = 60
}
