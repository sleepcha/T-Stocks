//
// StopOrder.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Информация о стоп-заявке. */

public struct StopOrder: Decodable {
    public let stopOrderId: String
    public let instrumentUid: String
    public let figi: String
    public let lotsRequested: String
    public let direction: StopOrderDirection
    public let currency: String
    public let orderType: StopOrderType
    public let createDate: Date
    public let price: MoneyValue
    public let stopPrice: MoneyValue

    public let activationDateTime: Date?
    public let expirationTime: Date?
    public var takeProfitType: TakeProfitType?
    public var trailingData: StopOrderTrailingData?
    public var status: StopOrderStatusOption?
}
