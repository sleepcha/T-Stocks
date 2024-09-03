//
//  SandboxService.swift
//  T-Stocks
//
//  Created by sleepcha on 8/10/24.
//

import Foundation

// MARK: - Constants

private extension C {
    static let newAccountName = String(localized: "SandboxService.newAccountName", defaultValue: "Брокерский счёт")
    static let topUpAmount = Decimal(5_000_000)
    static let sandboxAccountAssets = [
        // shares
        "35fb8d6b-ed5f-45ca-b383-c4e3752c9a8a",
        "7de75794-a27f-4d81-a39b-492345813822",
        "e6123145-9665-43e0-8413-cd61b8aa9b13",
        "02cfdf61-6298-4c0f-a9ca-9cabc82afaf3",
        "eed9621b-6412-4f4b-a166-758882cc7a4c",
        // bonds
        "f1bfddbb-0086-46f1-bffe-930c5ece8cca",
        "c0233e22-a823-4b14-90cf-143b251f7d32",
        "b6e4ff26-6617-42e5-a663-f1f47d91f60d",
        "79d41d32-a00a-4016-b6cb-893fcc059a06",
        "afeed796-fe26-4cd3-aab1-77648b724689",
        // futures
        "b347fe28-0d2a-45bf-b3bd-cda8a6ac64e6",
        "bd4cdf9d-4103-458b-ba87-4686ffc9c36f",
        "48706c30-0bd7-42ad-a936-150287cd9de4",
        // etfs
        "4c466956-d2ce-4a95-abb4-17947a65f18a",
        "a9ff2a1a-f8de-4648-8d5a-6b264f32fcdf",
        "ade12bc5-07d9-44fe-b27a-1543e05bacfd",
        "3783c7a7-4c20-49a8-8e28-f54229b414c8",
        "c2e5b5d7-fd56-48b3-8f28-d47ca7a09a67",
        // currencies
        "d6240afe-4e9c-49b6-8835-629f431c8506",
        "4587ab1d-a9c9-4910-a0d6-86c7b9c42510",
    ]
}

// MARK: - SandboxService

protocol SandboxService {
    func createAccount(completion: @escaping (RepositoryError?) -> Void) -> AsyncTask
    func closeAccount(_ accountID: String, completion: @escaping (RepositoryError?) -> Void) -> AsyncTask
}

// MARK: - SandboxServiceImpl

final class SandboxServiceImpl: SandboxService {
    let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func createAccount(completion: @escaping (RepositoryError?) -> Void) -> AsyncTask {
        var accountID: String?

        return AsyncChain {
            let openSandboxAccount = API.openSandboxAccount(OpenSandboxAccountRequest(name: C.newAccountName))
            return self.networkManager.fetch(openSandboxAccount, retryCount: 0) { accountID = $0.success?.accountId }
        }.then {
            guard let accountID else { return .empty() }
            return self.fillPortfolio(accountID)
        }.handle { state in
            switch state {
            case .failed(let error as NetworkManagerError):
                completion(RepositoryError(error))
            default:
                completion(nil)
            }
        }
    }

    func closeAccount(_ accountID: String, completion: @escaping (RepositoryError?) -> Void) -> AsyncTask {
        let endpoint = API.closeSandboxAccount(CloseSandboxAccountRequest(accountId: accountID))
        return networkManager.fetch(endpoint) { completion($0.failure.map(RepositoryError.init)) }
    }

    private func fillPortfolio(_ accountID: String) -> AsyncTask {
        AsyncChain {
            let payIn = API.sandboxPayIn(SandboxPayInRequest(accountId: accountID, amount: C.topUpAmount.asMoney("RUB")))
            return self.networkManager.fetch(payIn) { _ in }
        }.then {
            let postOrders = C.sandboxAccountAssets
                .map { (accountID, $0) }
                .map(self.postOrder)
            return AsyncGroup(postOrders)
        }
    }

    private func postOrder(accountID: String, instrumentID: String) -> AsyncTask {
        let order = PostOrderRequest(
            accountId: accountID,
            instrumentId: instrumentID,
            orderId: UUID().uuidString,
            orderType: .market,
            direction: .buy,
            quantity: String(Int.random(in: 1...50))
        )

        return networkManager.fetch(API.postOrder(order), retryCount: 0) {
            if let err = $0.failure { print("buy_error: \(order.instrumentId) [\(err)]") }
        }
    }
}
