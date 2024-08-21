//
//  AssetRepository.swift
//  T-Stocks
//
//  Created by sleepcha on 7/16/24.
//

import Foundation

// MARK: - Constants

private extension Expiry.Period {
    #if DEBUG
    static let assetCachingPeriod = Self.month(12)
    #else
    static let assetCachingPeriod = Self.month(1)
    #endif
}

// MARK: - AssetRepository

protocol AssetRepository {
    func getAssets(_ assetIDs: [String], completion: @escaping (RepositoryResult<[String: Asset]>) -> Void) -> AsyncTask
    func getClosePrices(_ assetIDs: [String], completion: @escaping (RepositoryResult<[String: Decimal]>) -> Void) -> AsyncTask
}

// MARK: - AssetRepositoryImpl

final class AssetRepositoryImpl: AssetRepository {
    private let networkManager: NetworkManager
    private let cachingManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        self.cachingManager = networkManager.caching(.for(.assetCachingPeriod))
    }

    func getAssets(_ assetIDs: [String], completion: @escaping (RepositoryResult<[String: Asset]>) -> Void) -> AsyncTask {
        guard !assetIDs.isEmpty else {
            return AsyncTask.empty { completion(.success([:])) }
        }

        var assets = [String: Asset]()
        let lock = NSLock()

        let tasks = assetIDs.map { id in
            cachingManager.fetch(API.getInstrumentBy(.init(id: id, idType: .typeUid))) { result in
                guard let instrument = result.success?.instrument else { return }
                lock.withLock { assets[id] = Asset(instrument: instrument) }
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

    func getClosePrices(_ assetIDs: [String], completion: @escaping (RepositoryResult<[String: Decimal]>) -> Void) -> AsyncTask {
        guard !assetIDs.isEmpty else {
            return AsyncTask.empty { completion(.success([:])) }
        }

        let instruments = assetIDs.map(InstrumentClosePriceRequest.init)

        return networkManager.fetch(API.getClosePrices(.init(instruments: instruments))) { result in
            completion(result
                .map(\.closePrices)
                .map { prices in prices.reduceToDictionary(key: \.instrumentUid, optionalValue: \.price?.asDecimal) }
                .mapError(RepositoryError.init)
            )
        }
    }
}

// MARK: - Model mapping

private extension Asset {
    init(instrument: Instrument) {
        self.init(
            id: instrument.uid,
            name: instrument.name,
            ticker: instrument.ticker,
            logoName: instrument.brand.logoName,
            currency: .init(rawValue: instrument.currency.lowercased()) ?? .other,
            lot: instrument.lot,
            isShortAvailable: instrument.shortEnabledFlag,
            kind: Kind(instrument.instrumentKind)
        )
    }
}

private extension Asset.Kind {
    init(_ instrumentType: InstrumentType) {
        self = switch instrumentType {
        case .share:
            .share
        case .bond:
            .bond
        case .etf:
            .etf
        case .futures:
            .futures
        case .option:
            .option
        case .sp:
            .structuredProduct
        case .currency:
            .currency
        default:
            .other
        }
    }
}
