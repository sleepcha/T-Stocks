//
//  API+Endpoints.swift
//  T-Stocks
//
//  Created by sleepcha on 8/29/24.
//

import Foundation

extension API {
    typealias POSTProvider<Request: Encodable, Response: Decodable> = (Request) -> POST<Request, Response>

    static let getAccounts = TInvestAPIClient.getAccounts.postProvider
    static let getPortfolio = TInvestAPIClient.getPortfolio.postProvider
    static let postOrder = TInvestAPIClient.postOrder.postProvider
    static let getClosePrices = TInvestAPIClient.getClosePrices.postProvider
    static let getCandles = TInvestAPIClient.getCandles.postProvider
    static let getInstrumentBy = TInvestAPIClient.getInstrumentBy.postProvider
    static let getShareBy = TInvestAPIClient.getShareBy.postProvider
    static let getBondBy = TInvestAPIClient.getBondBy.postProvider
    static let getETFBy = TInvestAPIClient.getETFBy.postProvider
    static let getFutureBy = TInvestAPIClient.getFutureBy.postProvider
    static let getOptionBy = TInvestAPIClient.getOptionBy.postProvider
    static let getCurrencyBy = TInvestAPIClient.getCurrencyBy.postProvider
    static let openSandboxAccount = TInvestAPIClient.openSandboxAccount.postProvider
    static let closeSandboxAccount = TInvestAPIClient.closeSandboxAccount.postProvider
    static let sandboxPayIn = TInvestAPIClient.sandboxPayIn.postProvider
}

private extension TInvestAPIClient.API {
    var postProvider: API.POSTProvider<Request, Response> {
        { request in
            API.POST(path: path, request: request)
        }
    }
}
