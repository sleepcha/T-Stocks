//
//  AssetRepository.swift
//  T-Stocks
//
//  Created by sleepcha on 7/16/24.
//

import Foundation

// MARK: - AssetRepository

protocol AssetRepository {
    func getAssets(_ assetIDs: [(String, AssetType)], completion: @escaping (RepositoryResult<[String: Asset]>) -> Void) -> AsyncTask
    func getClosePrices(_ assetIDs: [String], completion: @escaping (RepositoryResult<[String: Decimal]>) -> Void) -> AsyncTask
}

// MARK: - AssetRepositoryImpl

final class AssetRepositoryImpl: AssetRepository {
    private let networkManager: NetworkManager
    private let cachingManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        self.cachingManager = networkManager.caching(.for(C.assetCachingPeriod))
    }

    func getAssets(_ assetIDs: [(String, AssetType)], completion: @escaping (RepositoryResult<[String: Asset]>) -> Void) -> AsyncTask {
        guard !assetIDs.isEmpty else {
            return AsyncTask.empty { completion(.success([:])) }
        }

        var assets = [String: Asset]()
        let lock = NSLock()

        let tasks = assetIDs.map { id, type in
            self.getAsset(id, assetType: type) {
                guard let asset = $0.success else { return }
                lock.withLock { assets[id] = asset }
            }
        }

        return AsyncGroup(tasks, shouldCancelOnError: .always) {
            if let error = $0.first as? RepositoryError {
                completion(.failure(error))
            } else {
                completion(.success(assets))
            }
        }
    }

    // TODO: implement in-memory cache since assetIDs array is not a stable key for the HTTPClient cache
    func getClosePrices(_ assetIDs: [String], completion: @escaping (RepositoryResult<[String: Decimal]>) -> Void) -> AsyncTask {
        guard !assetIDs.isEmpty else {
            return AsyncTask.empty { completion(.success([:])) }
        }

        let instruments = assetIDs.map(InstrumentClosePriceRequest.init).sorted(using: KeyPathComparator(\.instrumentId))

        return networkManager.fetch(API.getClosePrices(.init(instruments: instruments))) { result in
            completion(result
                .map(\.closePrices)
                .map { prices in prices.reduceToDictionary(key: \.instrumentUid, optionalValue: \.price?.asDecimal) }
                .mapError(RepositoryError.init)
            )
        }
    }

    private func getAsset(_ assetID: String, assetType: AssetType, completion: @escaping (RepositoryResult<Asset>) -> Void) -> AsyncTask {
        func fetchAsset<Response: InstrumentResponseProtocol>(_ postProvider: API.POSTProvider<InstrumentRequest, Response>) -> AsyncTask {
            let request = InstrumentRequest(id: assetID, idType: .typeUid)

            return cachingManager.fetch(postProvider(request)) {
                completion($0
                    .map(\.instrument)
                    .map(Asset.init)
                    .mapError(RepositoryError.init)
                )
            }
        }

        return switch assetType {
        case .share: fetchAsset(API.getShareBy)
        case .bond: fetchAsset(API.getBondBy)
        case .etf: fetchAsset(API.getETFBy)
        case .future: fetchAsset(API.getFutureBy)
        case .option: fetchAsset(API.getOptionBy)
        case .currency: fetchAsset(API.getCurrencyBy)
        case .other: fetchAsset(API.getInstrumentBy)
        }
    }
}

// MARK: - Model mapping

private extension Asset {
    init(instrument: InstrumentProtocol) {
        let assetKind: Asset.Kind

        switch instrument {
        case let bond as Bond:
            let data = BondData(
                couponsPerYear: bond.couponQuantityPerYear,
                maturityDate: bond.maturityDate,
                faceValue: bond.nominal.asDecimal ?? 0,
                accruedInterest: bond.aciValue.asDecimal ?? 0,
                isPerpetual: bond.perpetualFlag,
                isFloater: bond.floatingCouponFlag,
                isAmortized: bond.amortizationFlag
            )
            assetKind = .bond(data)

        case let future as Future:
            let data = FutureData(
                priceIncrementValue: future.minPriceIncrementAmount?.asDecimal ?? 1,
                underlyingAssetSize: future.basicAssetSize.asDecimal ?? 0,
                expirationDate: future.expirationDate,
                initialMarginOnBuy: future.initialMarginOnBuy.asDecimal ?? 0,
                initialMarginOnSell: future.initialMarginOnSell.asDecimal ?? 0
            )
            assetKind = .future(data)

        case is Share:
            assetKind = .share

        case is Etf:
            assetKind = .etf

        case is Option:
            assetKind = .option

        case let currency as Currency:
            let data = CurrencyData(isoCode: currency.isoCurrencyName)
            assetKind = .currency(data)

        default:
            assetKind = .other
        }

        self.init(
            id: instrument.uid,
            name: instrument.name,
            ticker: instrument.ticker,
            brand: Brand(
                logoName: instrument.brand.logoName,
                bgColor: instrument.brand.logoBaseColor,
                textColor: instrument.brand.textColor
            ),
            currency: CurrencyType(isoCode: instrument.currency),
            lot: instrument.lot,
            minPriceIncrement: instrument.minPriceIncrement?.asDecimal ?? 0,
            isShortAvailable: instrument.shortEnabledFlag,
            kind: assetKind
        )
    }
}

// MARK: - Constants

private extension C {
    #if DEBUG
    static let assetCachingPeriod = Expiry.Period.month(1)
    #else
    static let assetCachingPeriod = Expiry.Period.week(1)
    #endif
}
