//
//  PortfolioDataRepository.swift
//  T-Stocks
//
//  Created by sleepcha on 10/23/24.
//

import Foundation

// MARK: - PortfolioDataRepository

protocol PortfolioDataRepository {
    func getPortfolioData(id: String) -> AsyncTask<PortfolioData, RepositoryError>
    func getAllPortfoliosData() -> AsyncTask<[PortfolioData], RepositoryError>

    // Swift concurrency versions
    func getPortfolioData(id: String) async throws -> PortfolioData
    func getAllPortfoliosData() async throws -> [PortfolioData]
}

// MARK: - PortfolioDataRepositoryImpl

final class PortfolioDataRepositoryImpl: PortfolioDataRepository {
    private let accounts: [AccountData]
    private let networkManager: NetworkManager

    init(accounts: [AccountData], networkManager: NetworkManager) {
        self.accounts = accounts
        self.networkManager = networkManager.caching { $0.adding(10, .second) }
    }

    func getPortfolioData(id: String) -> AsyncTask<PortfolioData, RepositoryError> {
        let accountName = accounts.first { $0.id == id }?.name ?? "Брокерский счёт"

        return networkManager
            .fetch(API.getPortfolio(PortfolioRequest(accountId: id)))
            .map { PortfolioData(from: $0, accountName: accountName) }
            .mapError(RepositoryError.init)
    }

    func getAllPortfoliosData() -> AsyncTask<[PortfolioData], RepositoryError> {
        var portfoliosData = [PortfolioData?](repeating: nil, count: accounts.count)
        let lock = NSLock()

        let tasks = accounts.map(\.id).enumerated().map { index, id in
            getPortfolioData(id: id).onSuccess { data in
                lock.withLock { portfoliosData[index] = data }
            }
        }

        return AsyncTask.group(tasks, shouldCancelOnError: .always).map { portfoliosData.compactMap(\.self) }
    }

    func getPortfolioData(id: String) async throws -> PortfolioData {
        try await withCheckedThrowingContinuation { completion in
            getPortfolioData(id: id).run {
                completion.resume(with: $0)
            }
        }
    }

    func getAllPortfoliosData() async throws -> [PortfolioData] {
        try await withCheckedThrowingContinuation { continuation in
            getAllPortfoliosData().run {
                continuation.resume(with: $0)
            }
        }
    }
}
