//
//  TinkoffInvestClient+Endpoints.swift
//  TinkoffStocks
//
//  Created by sleepcha on 11/22/23.
//

import Fetchup
import Foundation

extension TinkoffInvestClient {
    struct TinkoffInvestEndpoint<Response: Decodable>: APIResource {
        let method: HTTPMethod
        let path: URL
        let body: Data?

        init(path: URL, request: Encodable) {
            // all TinkoffInvest requests utilize POST method
            self.method = .post
            self.path = path
            self.body = Self.encoding(request)
        }

        /// Encodes an instance of Encodable type and returns its JSON representation.
        private static func encoding(_ object: Encodable) -> Data {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            encoder.dateEncodingStrategy = .iso8601
            encoder.nonConformingFloatEncodingStrategy = .convertToString(
                positiveInfinity: "Infinity",
                negativeInfinity: "-Infinity",
                nan: "NaN"
            )

            // by default, throw case is only possible when `nonConformingFloatEncodingStrategy` is set to `.throw`
            return try! encoder.encode(object)
        }
    }

    struct Endpoint<Request: Encodable, Response: Decodable> {
        let path: URL
        let request: Request.Type
        let response: Response.Type

        func callAsFunction(_ request: Request) -> TinkoffInvestEndpoint<Response> {
            TinkoffInvestEndpoint<Response>(path: path, request: request)
        }
    }

    // MARK: - Endpoints

    enum Endpoints {
        static let getAcccounts = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.UsersService/GetAccounts",
            request: GetAccountsRequest.self,
            response: GetAccountsResponse.self
        )

        static let getPortfolio = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.OperationsService/GetPortfolio",
            request: PortfolioRequest.self,
            response: PortfolioResponse.self
        )

        static let getLastOperations = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.OperationsService/GetOperationsByCursor",
            request: GetOperationsByCursorRequest.self,
            response: GetOperationsByCursorResponse.self
        )

        static let getCurrenciesList = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.InstrumentsService/Currencies",
            request: InstrumentsRequest.self,
            response: CurrenciesResponse.self
        )

        static let getBondsList = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.InstrumentsService/Bonds",
            request: InstrumentsRequest.self,
            response: BondsResponse.self
        )

        static let getSharesList = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.InstrumentsService/Shares",
            request: InstrumentsRequest.self,
            response: SharesResponse.self
        )

        static let getFuturesList = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.InstrumentsService/Futures",
            request: InstrumentsRequest.self,
            response: FuturesResponse.self
        )

        static let getBondCoupons = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.InstrumentsService/GetBondCoupons",
            request: GetBondCouponsRequest.self,
            response: GetBondCouponsResponse.self
        )

        static let getInstrumentBy = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.InstrumentsService/GetInstrumentBy",
            request: InstrumentRequest.self,
            response: InstrumentResponse.self
        )

        static let findInstrument = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.InstrumentsService/FindInstrument",
            request: FindInstrumentRequest.self,
            response: FindInstrumentResponse.self
        )

        static let getLastPrices = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.MarketDataService/GetLastPrices",
            request: GetLastPricesRequest.self,
            response: GetLastPricesResponse.self
        )

        static let getClosePrices = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.MarketDataService/GetClosePrices",
            request: GetClosePricesRequest.self,
            response: GetClosePricesResponse.self
        )

        static let getOrders = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.OrdersService/GetOrders",
            request: GetOrdersRequest.self,
            response: GetOrdersResponse.self
        )

        static let postOrder = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.OrdersService/PostOrder",
            request: PostOrderRequest.self,
            response: PostOrderResponse.self
        )

        static let postStopOrder = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.OrdersService/PostStopOrder",
            request: PostStopOrderRequest.self,
            response: PostStopOrderResponse.self
        )

        static let cancelOrder = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.OrdersService/CancelOrder",
            request: CancelOrderRequest.self,
            response: CancelOrderResponse.self
        )

        static let getOrderPrice = Endpoint(
            path: "/rest/tinkoff.public.invest.api.contract.v1.OrdersService/GetOrderPrice",
            request: GetOrderPriceRequest.self,
            response: GetOrderPriceResponse.self
        )
    }
}

// MARK: - Methods

extension TinkoffInvestClient {
    func getAccounts(completion: @escaping ResultHandler<[Account]>) -> AsyncTask {
        fetch(
            Endpoints.getAcccounts(GetAccountsRequest()),
            completion: { completion($0.map(\.accounts)) }
        )
    }

    func getPortfolio(_ accountID: String, completion: @escaping ResultHandler<PortfolioResponse>) -> AsyncTask {
        fetch(
            Endpoints.getPortfolio(PortfolioRequest(accountId: accountID, currency: .rub)),
            completion: completion
        )
    }

    func getCurrenciesList(completion: @escaping ResultHandler<[Currency]>) -> AsyncTask {
        fetch(
            Endpoints.getCurrenciesList(InstrumentsRequest(instrumentStatus: .base)),
            completion: { completion($0.map(\.instruments)) }
        )
    }

    func getBondsList(completion: @escaping ResultHandler<[Bond]>) -> AsyncTask {
        fetch(
            Endpoints.getBondsList(InstrumentsRequest(instrumentStatus: .base)),
            completion: { completion($0.map(\.instruments)) }
        )
    }

    func getSharesList(completion: @escaping ResultHandler<[Share]>) -> AsyncTask {
        fetch(
            Endpoints.getSharesList(InstrumentsRequest(instrumentStatus: .base)),
            completion: { completion($0.map(\.instruments)) }
        )
    }

    func getFuturesList(completion: @escaping ResultHandler<[Future]>) -> AsyncTask {
        fetch(
            Endpoints.getFuturesList(InstrumentsRequest(instrumentStatus: .base)),
            completion: { completion($0.map(\.instruments)) }
        )
    }

    func getInstrumentBy(_ id: InstrumentID, completion: @escaping ResultHandler<Instrument>) -> AsyncTask {
        fetch(
            Endpoints.getInstrumentBy(id.request),
            completion: { completion($0.map(\.instrument)) }
        )
    }

    func search(_ query: String, completion: @escaping ResultHandler<[InstrumentShort]>) -> AsyncTask {
        fetch(
            Endpoints.findInstrument(FindInstrumentRequest(query: query)),
            completion: { completion($0.map(\.instruments)) }
        )
    }

    func getLastOperations(_ request: GetOperationsByCursorRequest, completion: @escaping ResultHandler<GetOperationsByCursorResponse>) -> AsyncTask {
        fetch(
            Endpoints.getLastOperations(request),
            completion: completion
        )
    }

    func getLastPrices(_ instrumentsIDs: [String], completion: @escaping ResultHandler<[LastPrice]>) -> AsyncTask {
        fetch(
            Endpoints.getLastPrices(GetLastPricesRequest(instrumentId: instrumentsIDs)),
            completion: { completion($0.map(\.lastPrices)) }
        )
    }

    func getClosePrices(_ instrumentsIDs: [String], completion: @escaping ResultHandler<[InstrumentClosePriceResponse]>) -> AsyncTask {
        fetch(
            Endpoints.getClosePrices(GetClosePricesRequest(instruments: instrumentsIDs.map(InstrumentClosePriceRequest.init))),
            completion: { completion($0.map(\.closePrices)) }
        )
    }

    func getOrders(_ accountID: String, completion: @escaping ResultHandler<[OrderState]>) -> AsyncTask {
        fetch(
            Endpoints.getOrders(GetOrdersRequest(accountId: accountID)),
            completion: { completion($0.map(\.orders)) }
        )
    }

    func postOrder(_ accountID: String, instrumentID: String, order: OrderProtocol, completion: @escaping ResultHandler<PostOrderResponse>) -> AsyncTask {
        let request = PostOrderRequest(
            accountId: accountID,
            instrumentId: instrumentID,
            orderId: order.id,
            orderType: order.type,
            direction: order.direction,
            quantity: order.quantity,
            priceType: order.priceType,
            price: order.price
        )
        return fetch(Endpoints.postOrder(request), completion: completion)
    }

    func postStopOrder(_ request: PostStopOrderRequest, completion: @escaping ResultHandler<PostStopOrderResponse>) -> AsyncTask {
        fetch(Endpoints.postStopOrder(request), completion: completion)
    }

    func cancelOrder(_ accountID: String, orderID: String, completion: @escaping ResultHandler<Date>) -> AsyncTask {
        fetch(
            Endpoints.cancelOrder(CancelOrderRequest(accountId: accountID, orderId: orderID)),
            completion: { completion($0.map(\.time)) }
        )
    }

    func getOrderPrice(_ accountID: String, instrumentID: String, order: OrderProtocol, completion: @escaping ResultHandler<GetOrderPriceResponse>) -> AsyncTask {
        let request = GetOrderPriceRequest(
            accountId: accountID,
            instrumentId: instrumentID,
            price: order.price,
            direction: order.direction,
            quantity: order.quantity
        )
        return fetch(Endpoints.getOrderPrice(request), completion: completion)
    }
}
