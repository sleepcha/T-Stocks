//
//  TinkoffInvestClient.swift
//  BondsFilter
//
//  Created by sleepcha on 11/21/22.
//

import Foundation
import Fetchup


enum ServerEnvironment: URL {
    case prod = "https://invest-public-api.tinkoff.ru/rest"
    case sandbox = "https://sandbox-invest-public-api.tinkoff.ru/rest"
}

struct TinkoffAPI<Response: Decodable>: APIResource {
    let method: HTTPMethod = .post
    let endpoint: URL
    let body: Data?
}

final class TinkoffInvestClient: FetchupClientProtocol {
    typealias ResultCompletion<T> = (Result<T, Error>) -> Void
    static let rubleUID = "a92e2e25-a698-45cc-a781-167cf465257c"
    
    let configuration: FetchupClientConfiguration
    let session: URLSession
    let environment: ServerEnvironment
    
    init(token: String, environment: ServerEnvironment, urlSessionConfiguration: URLSessionConfiguration = .default) {
        let headers = [
            "Authorization" : "Bearer \(token)",
            "accept"        : "application/json",
            "Content-Type"  : "application/json",
            "x-app-name"    : "sleepcha.TinkoffStocks"
        ]
        
        let urlSessionConfiguration = urlSessionConfiguration
        urlSessionConfiguration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 512 * 1024 * 1024)
        urlSessionConfiguration.networkServiceType = .responsiveData
        urlSessionConfiguration.timeoutIntervalForRequest = 10
        urlSessionConfiguration.httpAdditionalHeaders = headers
        
        // 1. A hack for caching POST requests that really operate as GETs.
        // URLCache won't retrieve cached responses to POST requests that have an HTTP body (https://developer.apple.com/forums/thread/732010)
        // 2. The added query item containing a (piece of) token will guarantee a cache miss for different users fetching the same resource.
        let halfOfToken = String(token.prefix(44))
        let transformer = { (original: URLRequest) in
            var modified = original
            modified.httpMethod = "GET"
            modified.url?.append(queryItems: [URLQueryItem(name: "tinkoffClientCacheID", value: halfOfToken)])
            return modified
        }
        
        self.session = URLSession(configuration: urlSessionConfiguration)
        self.configuration = FetchupClientConfiguration(baseURL: environment.rawValue, manualCaching: true, modifyRequest: transformer)
        self.environment = environment
    }
    
    func getAccounts(expiresOn expirationDate: Date? = nil, completion: @escaping ResultCompletion<[Account]>) -> Operation {
        let endpoint: URL = (
            environment == .prod
            ? "/tinkoff.public.invest.api.contract.v1.UsersService/GetAccounts"
            : "/tinkoff.public.invest.api.contract.v1.SandboxService/GetSandboxAccounts"
        )
        
        let resource = TinkoffAPI<GetAccountsResponse>(
            endpoint: endpoint,
            body: GetAccountsRequest().encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate) {
            completion($0.map { $0.accounts ?? [] })
        }
    }
    
    func getPortfolio(_ accountID: String, expiresOn expirationDate: Date? = nil, completion: @escaping ResultCompletion<PortfolioResponse>) -> Operation {
        let endpoint: URL = (
            environment == .prod
            ? "/tinkoff.public.invest.api.contract.v1.OperationsService/GetPortfolio"
            : "/tinkoff.public.invest.api.contract.v1.SandboxService/GetSandboxPortfolio"
        )
        
        let resource = TinkoffAPI<PortfolioResponse>(
            endpoint: endpoint,
            body: PortfolioRequest(accountId: accountID, currency: .rub).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate, completion: completion)
    }
    
    func getBondsList(expiresOn expirationDate: Date? = nil, completion: @escaping ResultCompletion<[Bond]>) -> Operation {
        let endpoint: URL = "/tinkoff.public.invest.api.contract.v1.InstrumentsService/Bonds"
        
        let resource = TinkoffAPI<BondsResponse>(
            endpoint: endpoint,
            body: InstrumentsRequest(instrumentStatus: .base).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate) {
            completion($0.map { $0.instruments ?? [] })
        }
    }
    
    func getLastOperations(
        _ request: GetOperationsByCursorRequest,
        expiresOn expirationDate: Date? = nil,
        completion: @escaping ResultCompletion<GetOperationsByCursorResponse>
    ) -> Operation {
        let endpoint: URL = (
            environment == .prod
            ? "/tinkoff.public.invest.api.contract.v1.OperationsService/GetOperationsByCursor"
            : "/tinkoff.public.invest.api.contract.v1.SandboxService/GetSandboxOperationsByCursor"
        )
        
        let resource = TinkoffAPI<GetOperationsByCursorResponse>(
            endpoint: endpoint,
            body: request.encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate, completion: completion)
    }
    
    func getLastPrices(_ instrumentsIDs: [String], expiresOn expirationDate: Date? = nil, completion: @escaping ResultCompletion<[LastPrice]>) -> Operation {
        let endpoint: URL = "/tinkoff.public.invest.api.contract.v1.MarketDataService/GetLastPrices"
        
        let resource = TinkoffAPI<GetLastPricesResponse>(
            endpoint: endpoint,
            body: GetLastPricesRequest(instrumentId: instrumentsIDs).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate) {
            completion($0.map { $0.lastPrices ?? [] })
        }
    }
    
    func getClosePrices(
        _ instrumentsIDs: [String],
        expiresOn expirationDate: Date? = nil,
        completion: @escaping ResultCompletion<[InstrumentClosePriceResponse]>
    ) -> Operation {
        let endpoint: URL = "/tinkoff.public.invest.api.contract.v1.MarketDataService/GetClosePrices"
        
        let resource = TinkoffAPI<GetClosePricesResponse>(
            endpoint: endpoint,
            body: GetClosePricesRequest(
                instruments: instrumentsIDs.map { InstrumentClosePriceRequest(instrumentId: $0) }
            ).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate) {
            completion($0.map { $0.closePrices ?? [] })
        }
    }
    
    func getBondCoupons(
        _ figi: String,
        from: Date? = nil,
        to: Date? = nil,
        expiresOn expirationDate: Date? = nil,
        completion: @escaping ResultCompletion<[Coupon]>
    ) -> Operation {
        let endpoint: URL = "/tinkoff.public.invest.api.contract.v1.InstrumentsService/GetBondCoupons"
        
        let resource = TinkoffAPI<GetBondCouponsResponse>(
            endpoint: endpoint,
            body: GetBondCouponsRequest(figi: figi, from: from, to: to).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate) {
            completion($0.map { $0.events ?? [] })
        }
    }
    
    func getOrders(_ accountID: String, expiresOn expirationDate: Date? = nil, completion: @escaping ResultCompletion<[OrderState]>) -> Operation {
        let endpoint: URL = (
            environment == .prod
            ? "/tinkoff.public.invest.api.contract.v1.OrdersService/GetOrders"
            : "/tinkoff.public.invest.api.contract.v1.SandboxService/GetSandboxOrders"
        )
        
        let resource = TinkoffAPI<GetOrdersResponse>(
            endpoint: endpoint,
            body: GetOrdersRequest(accountId: accountID).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate) {
            completion($0.map { $0.orders ?? [] })
        }
    }
    
    func postOrder(
        _ accountID: String,
        instrumentID: String,
        orderType: OrderType,
        direction: OrderDirection,
        quantity: Int,
        price: Decimal? = nil,
        orderID: String,
        expiresOn expirationDate: Date? = nil,
        completion: @escaping ResultCompletion<PostOrderResponse>
    ) -> Operation {
        let endpoint: URL = (
            environment == .prod
            ? "/tinkoff.public.invest.api.contract.v1.OrdersService/PostOrder"
            : "/tinkoff.public.invest.api.contract.v1.SandboxService/PostSandboxOrder"
        )
        
        let resource = TinkoffAPI<PostOrderResponse>(
            endpoint: endpoint,
            body: PostOrderRequest(
                quantity: String(quantity),
                price: price?.asQuotation,
                direction: direction,
                accountId: accountID,
                orderType: orderType,
                orderId: orderID,
                instrumentId: instrumentID
            ).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate, completion: completion)
    }
    
    func cancelOrder(_ accountID: String, orderID: String, expiresOn expirationDate: Date? = nil, completion: @escaping ResultCompletion<Date?>) -> Operation {
        let endpoint: URL = (
            environment == .prod
            ? "/tinkoff.public.invest.api.contract.v1.OrdersService/CancelOrder"
            : "/tinkoff.public.invest.api.contract.v1.SandboxService/CancelSandboxOrder"
        )
        
        let resource = TinkoffAPI<CancelOrderResponse>(
            endpoint: endpoint,
            body: CancelOrderRequest(accountId: accountID, orderId: orderID).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate) {
            completion($0.map { $0.time })
        }
    }
    
    func getOrderBook(
        _ instrumentID: String,
        depth: Int,
        expiresOn expirationDate: Date? = nil,
        completion: @escaping ResultCompletion<GetOrderBookResponse>
    ) -> Operation {
        let endpoint: URL = "/tinkoff.public.invest.api.contract.v1.MarketDataService/GetOrderBook"
        
        let resource = TinkoffAPI<GetOrderBookResponse>(
            endpoint: endpoint,
            body: GetOrderBookRequest(depth: depth, instrumentId: instrumentID).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate, completion: completion)
    }
    
    func getFuturesMargin(
        _ figi: String,
        expiresOn expirationDate: Date? = nil,
        completion: @escaping ResultCompletion<GetFuturesMarginResponse>
    ) -> Operation {
        let endpoint: URL = "/tinkoff.public.invest.api.contract.v1.InstrumentsService/GetFuturesMargin"
        
        let resource = TinkoffAPI<GetFuturesMarginResponse>(
            endpoint: endpoint,
            body: GetFuturesMarginRequest(figi: figi).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate, completion: completion)
    }
    
    func getInstrumentBy(
        _ idType: InstrumentIdType,
        classCode: String? = nil,
        id: String,
        expiresOn expirationDate: Date? = nil,
        completion: @escaping ResultCompletion<Instrument?>
    ) -> Operation {
        let endpoint: URL = "/tinkoff.public.invest.api.contract.v1.InstrumentsService/GetInstrumentBy"
        
        let resource = TinkoffAPI<InstrumentResponse>(
            endpoint: endpoint,
            body: InstrumentRequest(idType: idType, classCode: classCode, id: id).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate) {
            completion($0.map { $0.instrument })
        }
    }
    
    func findInstruments(
        _ query: String,
        expiresOn expirationDate: Date? = nil,
        completion: @escaping ResultCompletion<[InstrumentShort]>
    ) -> Operation {
        let endpoint: URL = "/tinkoff.public.invest.api.contract.v1.InstrumentsService/FindInstrument"
        
        let resource = TinkoffAPI<FindInstrumentResponse>(
            endpoint: endpoint,
            body: FindInstrumentRequest(query: query).encoded()
        )
        
        return fetch(resource, expiresOn: expirationDate) {
            completion($0.map { $0.instruments ?? [] })
        }
    }
}

private extension Encodable {
    
    /// Encodes an instance of Encodable type and returns its JSON representation.
    func encoded() -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        // conscious decision to force unwrap
        return try! encoder.encode(self)
    }
}

extension FetchupClientProtocol {
    
    /// Returns an instance of async Operation that will return a cached resource (if available) or perform a network request.
    func fetch<T: APIResource>(
        _ resource: T,
        expiresOn expirationDate: Date? = nil,
        completion: @escaping (Result<T.Response, Error>) -> Void
    ) -> Operation {
        if expirationDate != nil, let cached = cached(resource) {
            return BlockOperation { completion(cached) }
        } else {
            let operation = NetworkOperation()
            operation.task = fetchDataTask(resource, expiresOn: expirationDate) { [weak operation] in
                completion($0)
                operation?.finish()
            }
            return operation
        }
    }
}

extension OperationQueue {
    func addOperations(_ operations: [Operation], completionQueue: OperationQueue = .main, completionHandler: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.addOperations(operations, waitUntilFinished: true)
            completionQueue.addOperation(completionHandler)
        }
    }
}

extension Operation {
    func add(to queue: OperationQueue) {
        queue.addOperation(self)
    }
}
