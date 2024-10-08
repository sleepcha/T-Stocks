//
// OrderState.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Информация о торговом поручении. */

public struct OrderState: Decodable {
    public let orderId: String
    public let instrumentUid: String
    public let figi: String
    public let executionReportStatus: OrderExecutionReportStatus
    public let lotsRequested: String
    public let lotsExecuted: String
    public let initialOrderPrice: MoneyValue
    public let executedOrderPrice: MoneyValue
    public let totalOrderAmount: MoneyValue
    public let averagePositionPrice: MoneyValue
    public let initialCommission: MoneyValue
    public let executedCommission: MoneyValue
    public let direction: OrderDirection
    public let initialSecurityPrice: MoneyValue

    /// Стадии выполнения заявки.
    public let stages: [OrderStage]
    public let serviceCommission: MoneyValue
    public let currency: String
    public let orderType: OrderType
    public let orderDate: Date

    /// Идентификатор ключа идемпотентности, переданный клиентом, в формате UID. Максимальная длина 36 символов.
    public let orderRequestId: String
}
