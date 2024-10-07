//
//  TInvestAPIClient+API.swift
//  T-Stocks
//
//  Created by sleepcha on 9/20/24.
//

import Foundation

extension TInvestAPIClient {
    struct API<Request: Encodable, Response: Decodable> {
        let method: HTTPMethod = .post
        let path: URL
        var body: Data?

        init(_ path: StaticString) { self.path = URL(string: "\(path)")! }

        func withRequest(_ request: Request, encoder: JSONEncoder) -> Self? {
            guard let encodedRequest = try? encoder.encode(request) else { return nil }
            var copy = self
            copy.body = encodedRequest
            return copy
        }
    }

    static let getAccounts = API<GetAccountsRequest, GetAccountsResponse>("tinkoff.public.invest.api.contract.v1.UsersService/GetAccounts")
    static let getPortfolio = API<PortfolioRequest, PortfolioResponse>("tinkoff.public.invest.api.contract.v1.OperationsService/GetPortfolio")
    static let getLastOperations = API<GetOperationsByCursorRequest, GetOperationsByCursorResponse>("tinkoff.public.invest.api.contract.v1.OperationsService/GetOperationsByCursor")
    static let getInstrumentBy = API<InstrumentRequest, InstrumentResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/GetInstrumentBy")
    static let getShareBy = API<InstrumentRequest, ShareResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/ShareBy")
    static let getBondBy = API<InstrumentRequest, BondResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/BondBy")
    static let getETFBy = API<InstrumentRequest, EtfResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/EtfBy")
    static let getFutureBy = API<InstrumentRequest, FutureResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/FutureBy")
    static let getOptionBy = API<InstrumentRequest, OptionResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/OptionBy")
    static let getCurrencyBy = API<InstrumentRequest, CurrencyResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/CurrencyBy")
    static let getBondCoupons = API<GetBondCouponsRequest, GetBondCouponsResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/GetBondCoupons")
    static let findInstrument = API<FindInstrumentRequest, FindInstrumentResponse>("tinkoff.public.invest.api.contract.v1.InstrumentsService/FindInstrument")
    static let getClosePrices = API<GetClosePricesRequest, GetClosePricesResponse>("tinkoff.public.invest.api.contract.v1.MarketDataService/GetClosePrices")
    static let getOrders = API<GetOrdersRequest, GetOrdersResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/GetOrders")
    static let postOrder = API<PostOrderRequest, PostOrderResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/PostOrder")
    static let postStopOrder = API<PostStopOrderRequest, PostStopOrderResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/PostStopOrder")
    static let cancelOrder = API<CancelOrderRequest, CancelOrderResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/CancelOrder")
    static let getOrderPrice = API<GetOrderPriceRequest, GetOrderPriceResponse>("tinkoff.public.invest.api.contract.v1.OrdersService/GetOrderPrice")
    static let openSandboxAccount = API<OpenSandboxAccountRequest, OpenSandboxAccountResponse>("tinkoff.public.invest.api.contract.v1.SandboxService/OpenSandboxAccount")
    static let closeSandboxAccount = API<CloseSandboxAccountRequest, CloseSandboxAccountResponse>("tinkoff.public.invest.api.contract.v1.SandboxService/CloseSandboxAccount")
    static let sandboxPayIn = API<SandboxPayInRequest, SandboxPayInResponse>("tinkoff.public.invest.api.contract.v1.SandboxService/SandboxPayIn")
}
