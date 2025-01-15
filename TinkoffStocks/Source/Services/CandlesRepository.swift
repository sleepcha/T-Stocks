//
//  CandlesRepository.swift
//  T-Stocks
//
//  Created by sleepcha on 1/3/25.
//

import Foundation

// MARK: - CandleStick

struct CandleStick {
    let open: Decimal
    let high: Decimal
    let low: Decimal
    let close: Decimal
    let volume: Decimal
    let date: Date
    let isComplete: Bool
}

// MARK: - CandleStickInterval

enum CandleStickInterval: CaseIterable {
    case min5
    case min15
    case min30
    case hour1
    case hour4
    case day
    case week
    case month
}

// MARK: - CandlesRepository

protocol CandlesRepository {
    func getCandles(_ assetID: String, interval: CandleStickInterval, limit: Int?, completion: @escaping Handler<Result<[CandleStick], RepositoryError>>)

    // Swift concurrency version
    func getCandles(_ assetID: String, interval: CandleStickInterval, limit: Int?) async throws -> [CandleStick]
}

// MARK: - CandlesRepositoryImpl

final class CandlesRepositoryImpl: CandlesRepository {
    private let networkManager: NetworkManager
    private let now: DateProvider

    init(networkManager: NetworkManager, dateProvider: @escaping DateProvider = Date.init) {
        self.networkManager = networkManager
        self.now = dateProvider
    }

    func getCandles(_ assetID: String, interval: CandleStickInterval, limit: Int?, completion: @escaping Handler<Result<[CandleStick], RepositoryError>>) {
        fetchCandles(assetID, interval: interval, limit: limit).run(completion: completion)
    }

    func getCandles(_ assetID: String, interval: CandleStickInterval, limit: Int?) async throws -> [CandleStick] {
        try await withCheckedThrowingContinuation { continuation in
            fetchCandles(assetID, interval: interval, limit: limit).run {
                continuation.resume(with: $0)
            }
        }
    }

    private func fetchCandles(_ assetID: String, interval: CandleStickInterval, limit: Int?) -> AsyncTask<[CandleStick], RepositoryError> {
        let daysAgo: Int = switch interval {
        case .min5: 7
        case .min15: 2 * 7
        case .min30: 2 * 7
        case .hour1: 2 * 7
        case .hour4: 2 * 30
        case .day: 6 * 30
        case .week: 2 * 365
        case .month: 5 * 365
        }

        let endpoint = API.getCandles(
            GetCandlesRequest(
                instrumentId: assetID,
                from: Date.now.adding(-daysAgo, .day),
                to: Date.now,
                interval: CandleInterval(from: interval),
                limit: limit
            )
        )

        return networkManager
            .fetch(endpoint)
            .mapError(RepositoryError.init)
            .map { $0.candles.map(CandleStick.init) }
    }
}

// MARK: - Model mapping

private extension CandleStick {
    init(from candle: HistoricCandle) {
        self.init(
            open: candle.open.asDecimal ?? 0,
            high: candle.high.asDecimal ?? 0,
            low: candle.low.asDecimal ?? 0,
            close: candle.close.asDecimal ?? 0,
            volume: Decimal(string: candle.volume) ?? 0,
            date: candle.time,
            isComplete: candle.isComplete
        )
    }
}

private extension CandleInterval {
    init(from interval: CandleStickInterval) {
        self = switch interval {
        case .min5: ._5min
        case .min15: ._15min
        case .min30: ._30min
        case .hour1: .hour
        case .hour4: ._4hour
        case .day: .day
        case .week: .week
        case .month: .month
        }
    }
}
