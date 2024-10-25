//
//  PortfolioService.swift
//  T-Stocks
//
//  Created by sleepcha on 7/25/24.
//

import Foundation

// MARK: - PortfolioService

protocol PortfolioService {
    func getAllPortfolios(completion: @escaping Handler<Result<[Portfolio], RepositoryError>>)
}

// MARK: - PortfolioServiceImpl

final class PortfolioServiceImpl: PortfolioService {
    let accounts: [AccountData]
    let portfolioDataRepo: PortfolioDataRepository
    let assetRepo: AssetRepository
    let closePricesRepo: ClosePricesRepository

    init(
        accounts: [AccountData],
        portfolioDataRepository: PortfolioDataRepository,
        assetRepository: AssetRepository,
        closePricesRepo: ClosePricesRepository
    ) {
        self.accounts = accounts
        self.portfolioDataRepo = portfolioDataRepository
        self.assetRepo = assetRepository
        self.closePricesRepo = closePricesRepo
    }

    func getAllPortfolios(completion: @escaping Handler<Result<[Portfolio], RepositoryError>>) {
        guard !accounts.isEmpty else {
            completion(.success([]))
            return
        }

        getAllPortfoliosData(accountIDs: accounts.map(\.id))
            .then { portfoliosData in
                // get rid of duplicate assets (Set) across multiple portfolios (flatMap)
                let assetIDs: Set<AssetID> = Set(portfoliosData.values.flatMap(\.openPositions).map(\.assetID))
                print(portfoliosData.values.flatMap(\.openPositions).count, "vs", assetIDs.count)
                return self.getAssets(Array(assetIDs)).map { assets in (assetIDs.map(\.id), portfoliosData, assets) }
            }.then { (assetIDs, portfoliosData, assets) in
                self.closePricesRepo.getClosePrices(assetIDs).map { closePrices in (portfoliosData, assets, closePrices) }
            }.onCancel {
                completion(.failure(.taskCancelled))
            }.run { result in
                switch result {
                case .success(let (portfoliosData, assets, closePrices)):
                    let portfolios = self.makePortfolios(portfoliosData: portfoliosData, assets: assets, closePrices: closePrices)
                    completion(.success(portfolios))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    private func getAllPortfoliosData(accountIDs: [String]) -> AsyncTask<[String: PortfolioData], RepositoryError> {
        var portfoliosData = [String: PortfolioData]()
        let lock = NSLock()

        let tasks = accountIDs.map { id in
            portfolioDataRepo.getPortfolioData(id: id).onSuccess { data in
                lock.withLock { portfoliosData[id] = data }
            }
        }

        return AsyncTask.group(tasks, shouldCancelOnError: .always).map { portfoliosData }
    }

    private func getAssets(_ assetIDs: [AssetID]) -> AsyncTask<[String: Asset], RepositoryError> {
        guard !assetIDs.isEmpty else { return .empty(.success([:])) }

        var assets = [String: Asset]()
        let lock = NSLock()

        let tasks = assetIDs.map { assetID in
            self.assetRepo.getAsset(assetID).onSuccess { asset in
                lock.withLock { assets[assetID.id] = asset }
            }
        }

        return AsyncTask.group(tasks, shouldCancelOnError: .always).map { assets }
    }

    /// `portfoliosData` key corresponds to account ID.
    /// `assets` and `closePrices` keys correspond to asset IDs.
    private func makePortfolios(
        portfoliosData: [String: PortfolioData],
        assets: [String: Asset],
        closePrices: [String: Decimal]
    ) -> [Portfolio] {
        accounts.compactMap { account in
            guard let portfolioData = portfoliosData[account.id]
            else { return nil }

            let positions = portfolioData.openPositions
                .reduceToDictionary(key: \.instrumentID, value: \.self)
                .mapValues { position in
                    let id = position.instrumentID
                    let asset = assets[id] ?? .empty(id: id)
                    return Portfolio.Item(openPosition: position, asset: asset, closePrice: closePrices[id])
                }

            return Portfolio(
                account: account,
                totalAmount: portfolioData.totalValue,
                items: positions
            )
        }
    }
}

// MARK: - Model mapping

private extension Portfolio.Item {
    init(openPosition: PortfolioData.OpenPosition, asset: Asset, closePrice: Decimal?) {
        self.init(
            quantity: openPosition.quantity,
            currentPrice: asset.isRuble ? 1 : openPosition.currentPrice,
            averagePrice: openPosition.averagePrice,
            closePrice: closePrice,
            isBlocked: openPosition.isBlockedInstrument,
            asset: asset
        )
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

extension PortfolioData.OpenPosition {
    var assetID: AssetID {
        let assetKind: AssetID.AssetKind = switch instrumentType {
        case "share": .share
        case "bond": .bond
        case "etf": .etf
        case "option": .option
        case "futures": .future
        case "currency": .currency
        default: .other
        }

        return AssetID(id: instrumentID, kind: assetKind)
    }
}

// MARK: - Constants

private extension C {
    static let emptyAssetName = String(localized: "PortfolioService.emptyAssetName", defaultValue: "Неизвестный актив")
}
