//
//  PortfolioService.swift
//  T-Stocks
//
//  Created by sleepcha on 7/25/24.
//

import Foundation

// MARK: - Constants

private extension String {
    static let emptyAssetName = String(localized: "PortfolioService.emptyAssetName", defaultValue: "Неизвестный актив")
}

// MARK: - PortfolioService

protocol PortfolioService {
    func getAllPortfolios(completion: @escaping (RepositoryResult<[Portfolio]>) -> Void) -> AsyncTask
}

// MARK: - PortfoliosServiceImpl

final class PortfoliosServiceImpl: PortfolioService {
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
            let itemIDs = portfoliosData.values.flatMap(\.items).map(\.id)

            let tasks = [
                assetRepo.getAssets(itemIDs) { assets = $0.success ?? [:] },
                assetRepo.getClosePrices(itemIDs) { closePrices = $0.success ?? [:] },
            ]
            return AsyncGroup(tasks, shouldCancelOnError: .always)
        }.handle { state in
            switch state {
            case .cancelled:
                completion(.failure(.taskCancelled))
            case .failed(let error as RepositoryError):
                completion(.failure(error))
            case .failed:
                // degenerate case, does not happen if all tasks in the chain complete with RepositoryError
                completion(.failure(.serverError))
            case .completed:
                let portfolios = self.makePortfolios(portfoliosData: portfoliosData, assets: assets, closePrices: closePrices)
                completion(.success(portfolios))
            case .ready, .executing:
                // impossible states
                break
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
                gainPercent: portfolioData.gainPercent,
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
            id: item.id,
            quantity: item.quantity,
            currentPrice: item.currentPrice,
            averagePrice: item.averagePrice,
            closePrice: closePrice,
            accruedInterest: item.accruedInterest,
            gain: item.gain,
            name: asset.name,
            ticker: asset.ticker,
            logoName: asset.logoName,
            currency: asset.currency,
            assetKind: asset.kind
        )
    }
}

private extension Asset {
    static func empty(id: String) -> Asset {
        Asset(
            id: id,
            name: .emptyAssetName,
            ticker: "?",
            logoName: "",
            currency: .other,
            lot: 1,
            isShortAvailable: false,
            kind: .other
        )
    }
}
