//
//  API.swift
//  T-Stocks
//
//  Created by sleepcha on 7/19/24.
//

import Foundation

// MARK: - API

enum API {
    struct POST<Request: Encodable, Response: Decodable>: Endpoint {
        let method: HTTPMethod = .post
        let path: URL
        let body: Data?

        init(_ path: URL, body: Data? = nil) {
            self.path = path
            self.body = body
        }

        func callAsFunction(_ request: Request) -> POST {
            let data = try? JSONEncoder.custom.encode(request)
            return POST(path, body: data)
        }
    }

    static let getAccounts = POST<GetAccountsRequest, GetAccountsResponse>("tinkoff.public.invest.api.contract.v1.UsersService/GetAccounts")
    static let getPortfolio = POST<PortfolioRequest, PortfolioResponse>("tinkoff.public.invest.api.contract.v1.OperationsService/GetPortfolio")
    static let getLastOperations = POST<GetOperationsByCursorRequest, GetOperationsByCursorResponse>("tinkoff.public.invest.api.contract.v1.OperationsService/GetOperationsByCursor")
    static let getInstrumentBy = POST<InstrumentRequest, InstrumentResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/GetInstrumentBy")
    static let getShareBy = POST<InstrumentRequest, ShareResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/ShareBy")
    static let getBondBy = POST<InstrumentRequest, BondResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/BondBy")
    static let getETFBy = POST<InstrumentRequest, EtfResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/EtfBy")
    static let getFutureBy = POST<InstrumentRequest, FutureResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/FutureBy")
    static let getOptionBy = POST<InstrumentRequest, OptionResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/OptionBy")
    static let getCurrencyBy = POST<InstrumentRequest, CurrencyResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/CurrencyBy")
    static let getBondCoupons = POST<GetBondCouponsRequest, GetBondCouponsResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/GetBondCoupons")
    static let findInstrument = POST<FindInstrumentRequest, FindInstrumentResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/FindInstrument")
    static let getClosePrices = POST<GetClosePricesRequest, GetClosePricesResponse>("tinkoff.public.invest.api.contract.v1.MarketDataService/GetClosePrices")
    static let getOrders = POST<GetOrdersRequest, GetOrdersResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/GetOrders")
    static let postOrder = POST<PostOrderRequest, PostOrderResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/PostOrder")
    static let postStopOrder = POST<PostStopOrderRequest, PostStopOrderResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/PostStopOrder")
    static let cancelOrder = POST<CancelOrderRequest, CancelOrderResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/CancelOrder")
    static let getOrderPrice = POST<GetOrderPriceRequest, GetOrderPriceResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/GetOrderPrice")
    static let openSandboxAccount = POST<OpenSandboxAccountRequest, OpenSandboxAccountResponse>("tinkoff.public.invest.api.contract.v1.SandboxService/OpenSandboxAccount")
    static let closeSandboxAccount = POST<CloseSandboxAccountRequest, CloseSandboxAccountResponse>("tinkoff.public.invest.api.contract.v1.SandboxService/CloseSandboxAccount")
    static let sandboxPayIn = POST<SandboxPayInRequest, SandboxPayInResponse>("tinkoff.public.invest.api.contract.v1.SandboxService/SandboxPayIn")
}
