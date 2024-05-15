//
// Future.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Объект передачи информации о фьючерсе. */

public struct Future: Codable {
    public let uid: String
    public let positionUid: String
    public let figi: String
    public let ticker: String
    public let classCode: String
    public let lot: Int
    public let currency: String
    public let name: String
    public let sector: String
    public let exchange: String
    public let realExchange: RealExchange
    public let countryOfRisk: String
    public let countryOfRiskName: String
    public let tradingStatus: SecurityTradingStatus
    public let expirationDate: Date
    public let firstTradeDate: Date

    /// Дата в часовом поясе UTC, до которой возможно проведение операций с фьючерсом.
    public let lastTradeDate: Date

    /// Шаг цены в пунктах.
    public let minPriceIncrement: Quotation

    /// Стоимость шага цены в валюте.
    public let minPriceIncrementAmount: Quotation

    /// Базовый актив.
    public let basicAsset: String
    public let basicAssetSize: Quotation
    public let basicAssetPositionUid: String

    /// Тип фьючерса.
    ///
    /// Возможные значения:
    /// - **physical_delivery** — физические поставки
    /// - **cash_settlement** — денежный эквивалент
    public let futuresType: String

    /// Тип актива.
    ///
    /// Возможные значения:
    /// - **commodity** — товар
    /// - **currency** — валюта
    /// - **security** — ценная бумага
    /// - **index** — индекс
    public let assetType: String

    public let shortEnabledFlag: Bool
    public let otcFlag: Bool
    public let buyAvailableFlag: Bool
    public let sellAvailableFlag: Bool
    public let apiTradeAvailableFlag: Bool
    public let forIisFlag: Bool
    public let forQualInvestorFlag: Bool
    public let weekendFlag: Bool
    public let blockedTcaFlag: Bool

    /// Гарантийное обеспечение при покупке.
    public let initialMarginOnBuy: MoneyValue

    /// Гарантийное обеспечение при продаже.
    public let initialMarginOnSell: MoneyValue

    /// Логотип и цветовая схема.
    public let brand: BrandData

    public let klong: Quotation?
    public let kshort: Quotation?
    public let dlong: Quotation?
    public let dshort: Quotation?
    public let dlongMin: Quotation?
    public let dshortMin: Quotation?
    public let first1minCandleDate: Date?
    public let first1dayCandleDate: Date?
}
