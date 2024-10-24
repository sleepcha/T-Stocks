//
//  AssetRepository.swift
//  T-Stocks
//
//  Created by sleepcha on 7/16/24.
//

import Foundation

// MARK: - AssetRepository

protocol AssetRepository {
    func getAsset(_ assetID: AssetID) -> AsyncTask<Asset, RepositoryError>
    func getAsset(_ assetID: AssetID, completion: @escaping Handler<Result<Asset, RepositoryError>>)
}

// MARK: - AssetRepositoryImpl

final class AssetRepositoryImpl: AssetRepository {
    private let networkManager: NetworkManager
    private let cachingManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        self.cachingManager = networkManager.caching(.for(C.assetCachingPeriod))
    }

    func getAsset(_ assetID: AssetID) -> AsyncTask<Asset, RepositoryError> {
        func fetchAsset<Response: AnyInstrumentResponse>(_ postProvider: API.POSTProvider<InstrumentRequest, Response>) -> AsyncTask<Asset, RepositoryError> {
            let request = InstrumentRequest(id: assetID.id, idType: .typeUid)
            return cachingManager
                .fetch(postProvider(request))
                .map { Asset(from: $0.instrument) }
                .mapError(RepositoryError.init)
        }

        return switch assetID.kind {
        case .share: fetchAsset(API.getShareBy)
        case .bond: fetchAsset(API.getBondBy)
        case .etf: fetchAsset(API.getETFBy)
        case .future: fetchAsset(API.getFutureBy)
        case .option: fetchAsset(API.getOptionBy)
        case .currency: fetchAsset(API.getCurrencyBy)
        case .other: fetchAsset(API.getInstrumentBy)
        }
    }

    func getAsset(_ assetID: AssetID, completion: @escaping Handler<Result<Asset, RepositoryError>>) {
        getAsset(assetID).run(completion: completion)
    }
}

// MARK: - Model mapping

private extension Asset {
    init(from instrument: AnyInstrument) {
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
            let data = CurrencyData(
                isoCode: currency.isoCurrencyName,
                isMetal: (currency.exchange == C.ID.metalExchange)
            )
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
