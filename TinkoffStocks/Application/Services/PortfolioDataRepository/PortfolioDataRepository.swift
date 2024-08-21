//
//  PortfolioDataRepository.swift.swift
//  T-Stocks
//
//  Created by sleepcha on 8/18/24.
//

import Foundation

// MARK: - PortfolioDataRepository

protocol PortfolioDataRepository {
    func getPortfoliosData(accountIDs: [String], completion: @escaping (RepositoryResult<[String: PortfolioData]>) -> Void) -> AsyncTask
}

// MARK: - PortfolioDataRepositoryImpl

final class PortfolioDataRepositoryImpl: PortfolioDataRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getPortfoliosData(accountIDs: [String], completion: @escaping (RepositoryResult<[String: PortfolioData]>) -> Void) -> AsyncTask {
        guard !accountIDs.isEmpty else {
            return AsyncTask.empty { completion(.success([:])) }
        }

        var result = [String: PortfolioData]()
        let lock = NSLock()

        let tasks = accountIDs.map { id in
            getPortfolioData(accountID: id) {
                guard let data = $0.success else { return }
                lock.withLock { result[id] = data }
            }
        }

        return AsyncGroup(tasks, shouldCancelOnError: .always) {
            if let error = $0.first as? RepositoryError {
                completion(.failure(error))
            } else {
                completion(.success(result))
            }
        }
    }

    // MARK: Private

    private func getPortfolioData(accountID: String, completion: @escaping (RepositoryResult<PortfolioData>) -> Void) -> AsyncTask {
        networkManager.fetch(
            API.getPortfolio(PortfolioRequest(accountId: accountID)),
            completion: { completion($0.map(PortfolioData.init).mapError(RepositoryError.init)) }
        )
    }
}

// MARK: - Model mapping

private extension PortfolioData {
    init(_ response: PortfolioResponse) {
        self.init(
            id: response.accountId,
            gainPercent: response.expectedYield?.asDecimal ?? 0,
            totalAmount: response.totalAmountPortfolio.asDecimal ?? 0,
            items: response.positions.map(Item.init)
        )
    }
}

private extension PortfolioData.Item {
    init(_ position: PortfolioPosition) {
        self.init(
            id: position.instrumentUid,
            kind: Kind(rawValue: position.instrumentType.lowercased()) ?? .other,
            quantity: position.quantity.asDecimal ?? 0,
            currentPrice: position.currentPrice?.asDecimal ?? 0,
            averagePrice: position.averagePositionPriceFifo?.asDecimal ?? 0,
            accruedInterest: position.currentNkd?.asDecimal ?? 0,
            gain: position.expectedYieldFifo?.asDecimal ?? 0
        )
    }
}
