//
//  PortfolioDataRepository.swift
//  T-Stocks
//
//  Created by sleepcha on 10/23/24.
//

// MARK: - PortfolioDataRepository

protocol PortfolioDataRepository {
    func getPortfolioData(id: String) -> AsyncTask<PortfolioData, RepositoryError>
    func getPortfolioData(id: String, completion: @escaping Handler<Result<PortfolioData, RepositoryError>>)
}

// MARK: - PortfolioDataRepositoryImpl

final class PortfolioDataRepositoryImpl: PortfolioDataRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getPortfolioData(id: String) -> AsyncTask<PortfolioData, RepositoryError> {
        networkManager
            .fetch(API.getPortfolio(PortfolioRequest(accountId: id)))
            .map(PortfolioData.init)
            .mapError(RepositoryError.init)
    }

    func getPortfolioData(id: String, completion: @escaping Handler<Result<PortfolioData, RepositoryError>>) {
        getPortfolioData(id: id).run(completion: completion)
    }
}
