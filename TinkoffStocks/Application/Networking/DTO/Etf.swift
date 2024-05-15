//
// Etf.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Объект передачи информации об инвестиционном фонде. */

public struct Etf: Codable {
    public let uid: String
    public let figi: String
    public let ticker: String
    public let classCode: String
    public let isin: String
    public let positionUid: String
    public let brand: BrandData
    public let lot: Int
    public let currency: String
    public let name: String
    public let exchange: String
    public let realExchange: RealExchange
    public let focusType: String
    public let countryOfRisk: String
    public let countryOfRiskName: String
    public let sector: String
    public let rebalancingFreq: String
    public let tradingStatus: SecurityTradingStatus

    public let shortEnabledFlag: Bool
    public let otcFlag: Bool
    public let buyAvailableFlag: Bool
    public let sellAvailableFlag: Bool
    public let apiTradeAvailableFlag: Bool
    public let forIisFlag: Bool
    public let forQualInvestorFlag: Bool
    public let weekendFlag: Bool
    public let blockedTcaFlag: Bool

    public let klong: Quotation?
    public let kshort: Quotation?
    public let dlong: Quotation?
    public let dshort: Quotation?
    public let dlongMin: Quotation?
    public let dshortMin: Quotation?
    public let first1minCandleDate: Date?
    public let first1dayCandleDate: Date?
    public let releasedDate: Date?
    public let numShares: Quotation?
    public let fixedCommission: Quotation?
    public let minPriceIncrement: Quotation?
}
