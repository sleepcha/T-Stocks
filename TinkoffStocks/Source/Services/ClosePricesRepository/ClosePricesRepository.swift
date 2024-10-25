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

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    // TODO: implement in-memory cache since assetIDs array is not a consistent key for the HTTPClient cache
    func getClosePrices(_ assetIDs: [String]) -> AsyncTask<[String: Decimal], RepositoryError> {
        guard !assetIDs.isEmpty else {
            return AsyncTask.empty(.success([:]))
        }

        let instruments = assetIDs.map(InstrumentClosePriceRequest.init)

        return networkManager
            .fetch(API.getClosePrices(.init(instruments: instruments)))
            .map { $0.closePrices.reduceToDictionary(key: \.instrumentUid, optionalValue: \.closePrice) }
            .mapError(RepositoryError.init)
    }
}

// MARK: - Helpers

private extension InstrumentClosePriceResponse {
    var closePrice: Decimal? {
        (eveningSessionPrice ?? price)?.asDecimal
    }
}
