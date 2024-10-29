//
//  ClosePricesRepositoryImpl.swift
//  T-Stocks
//
//  Created by sleepcha on 10/23/24.
//

import Foundation

// MARK: - ClosePricesRepository

protocol ClosePricesRepository {
    func getClosePrices(_ assetIDs: [String]) -> AsyncTask<[String: Decimal], RepositoryError>
}

// MARK: - ClosePricesRepositoryImpl

final class ClosePricesRepositoryImpl: ClosePricesRepository {
    private let networkManager: NetworkManager
    private let cache: Cache<Decimal>
    private let now: DateProvider

    init(networkManager: NetworkManager, dateProvider: @escaping DateProvider = Date.init) {
        self.networkManager = networkManager
        self.cache = Cache<Decimal>(dateProvider: dateProvider, countLimit: 10000)
        self.now = dateProvider
    }

    func getClosePrices(_ assetIDs: [String]) -> AsyncTask<[String: Decimal], RepositoryError> {
        guard !assetIDs.isEmpty else {
            return AsyncTask.empty(.success([:]))
        }

        var cachedPrices = [String: Decimal]()
        var requests = [InstrumentClosePriceRequest]()

        for assetID in assetIDs {
            guard assetID != C.ID.rubleAsset else { continue }

            if let cachedPrice = cache.get(key: assetID) {
                cachedPrices[assetID] = cachedPrice
            } else {
                requests.append(InstrumentClosePriceRequest(instrumentId: assetID))
            }
        }

        guard !requests.isEmpty else {
            return .empty(.success(cachedPrices))
        }

        return networkManager
            .fetch(API.getClosePrices(GetClosePricesRequest(instruments: requests)))
            .mapError(RepositoryError.init)
            .map { [weak cache, now] response in
                for item in response.closePrices {
                    cache?.store(
                        key: item.instrumentUid,
                        value: item.closePrice,
                        expiryDate: now().secondToMidnight
                    )
                    cachedPrices[item.instrumentUid] = item.closePrice
                }

                return cachedPrices
            }
    }
}

// MARK: - Helpers

private extension InstrumentClosePriceResponse {
    var closePrice: Decimal? {
        let mainSessionPrice = price?.asDecimal ?? 0
        let eveningSessionPrice = eveningSessionPrice?.asDecimal ?? 0

        // sometimes backend returns zero eveningSessionPrice for future assets
        return switch (mainSessionPrice, eveningSessionPrice) {
        case (0, 0): 0
        case (_, 0): mainSessionPrice
        default: eveningSessionPrice
        }
    }
}
