//
//  OrderProtocol.swift
//  TinkoffStocks
//
//  Created by sleepcha on 4/7/24.
//

import Foundation

// MARK: - OrderProtocol

protocol OrderProtocol {
    var id: String { get }
    var type: OrderType { get }
    var direction: OrderDirection { get }
    var quantity: String { get }
    var price: Quotation? { get }
    var priceType: PriceType? { get }
}

// MARK: - LimitOrder

struct LimitOrder: OrderProtocol {
    let id: String = UUID().uuidString
    let type: OrderType = .limit
    let direction: OrderDirection
    let quantity: String
    let price: Quotation?
    let priceType: PriceType?

    init(_ direction: OrderDirection, _ quantity: Int, _ price: Decimal, priceType: PriceType? = nil) {
        self.direction = direction
        self.quantity = String(quantity)
        self.price = price.asQuotation
        self.priceType = priceType
    }
}

// MARK: - MarketOrder

struct MarketOrder: OrderProtocol {
    let id: String = UUID().uuidString
    let type: OrderType = .market
    let direction: OrderDirection
    let quantity: String
    let price: Quotation? = nil
    let priceType: PriceType? = nil

    init(_ direction: OrderDirection, _ quantity: Int) {
        self.direction = direction
        self.quantity = String(quantity)
    }
}
