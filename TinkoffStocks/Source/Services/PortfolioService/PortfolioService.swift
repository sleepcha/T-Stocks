//
//  PortfolioService.swift
//  T-Stocks
//
//  Created by sleepcha on 7/25/24.
//

import Foundation

// MARK: - PortfolioService

protocol PortfolioService {
    func getAllPortfolios(completion: @escaping (RepositoryResult<[Portfolio]>) -> Void) -> AsyncTask
}

// MARK: - PortfolioServiceImpl

final class PortfolioServiceImpl: PortfolioService {
    let accounts: [AccountData]
    let portfolioDataRepo: PortfolioDataRepository
    let assetRepo: AssetRepository

    init(accounts: [AccountData], portfolioDataRepository: PortfolioDataRepository, assetRepository: AssetRepository) {
        self.accounts = accounts
        self.portfolioDataRepo = portfolioDataRepository
        self.assetRepo = assetRepository
    }

    func getAllPortfolios(completion: @escaping (RepositoryResult<[Portfolio]>) -> Void) -> AsyncTask {
        var portfoliosData = [String: PortfolioData]()
        var assets = [String: Asset]()
        var closePrices = [String: Decimal]()

        return AsyncChain { [self] in
            portfolioDataRepo.getPortfoliosData(accountIDs: accounts.map(\.id)) {
                portfoliosData = $0.success ?? [:]
            }
        }.then { [self] in
            // flatMap + dictionary to get rid of duplicate assets across portfolios
            let items = portfoliosData.values.flatMap(\.items).reduceToDictionary(key: \.id, value: \.kind.asAssetType)

            let tasks = [
                assetRepo.getAssets(Array(items)) { assets = $0.success ?? [:] },
                assetRepo.getClosePrices(items.map(\.key)) { closePrices = $0.success ?? [:] },
            ]
            return AsyncGroup(tasks, shouldCancelOnError: .always)
        }.handle { state in
            switch state {
            case .completed:
                let portfolios = self.makePortfolios(portfoliosData: portfoliosData, assets: assets, closePrices: closePrices)
                completion(.success(portfolios))
            case .failed(let error as RepositoryError):
                completion(.failure(error))
            case .cancelled:
                completion(.failure(.taskCancelled))
            default:
                // degenerate cases, do not happen if all tasks in the chain complete with RepositoryError
                completion(.failure(.taskCancelled))
            }
        }
    }

    private func makePortfolios(
        portfoliosData: [String: PortfolioData],
        assets: [String: Asset],
        closePrices: [String: Decimal]
    ) -> [Portfolio] {
        accounts.compactMap { account in
            guard let portfolioData = portfoliosData[account.id]
            else { return nil }

            let positions = portfolioData.items.map { item in
                let asset = assets[item.id] ?? .empty(id: item.id)
                return Portfolio.Position(item: item, asset: asset, closePrice: closePrices[item.id])
            }

            return Portfolio(
                account: account,
                totalAmount: portfolioData.totalAmount,
                positions: positions
            )
        }
    }
}

// MARK: - Model mapping

private extension Portfolio.Position {
    init(item: PortfolioData.Item, asset: Asset, closePrice: Decimal?) {
        self.init(
            quantity: item.quantity,
            currentPrice: item.currentPrice,
            averagePrice: item.averagePrice,
            closePrice: closePrice,
            isBlocked: item.isBlocked,
            asset: asset
        )
    }
}

private extension PortfolioData.Item.Kind {
    var asAssetType: AssetType {
        switch self {
        case .share: .share
        case .bond: .bond
        case .etf: .etf
        case .option: .option
        case .futures: .future
        case .currency: .currency
        case .sp, .other: .other
        }
    }
}

private extension Asset {
    static func empty(id: String) -> Asset {
        Asset(
            id: id,
            name: C.emptyAssetName,
            ticker: "?",
            brand: Brand(
                logoName: "",
                bgColor: "",
                textColor: ""
            ),
            currency: .other,
            lot: 1,
            minPriceIncrement: 1,
            isShortAvailable: false,
            kind: .other
        )
    }
}

// MARK: - Constants

private extension C {
    static let emptyAssetName = String(localized: "PortfolioService.emptyAssetName", defaultValue: "Неизвестный актив")
}
