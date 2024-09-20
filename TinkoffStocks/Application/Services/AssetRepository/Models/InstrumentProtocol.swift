//
//  InstrumentProtocol.swift
//  T-Stocks
//
//  Created by sleepcha on 7/27/24.
//

import Foundation

// MARK: - InstrumentProtocol

protocol InstrumentProtocol {
    var uid: String { get }
    var ticker: String { get }
    var classCode: String { get }
    var positionUid: String { get }
    var brand: BrandData { get }
    var lot: Int { get }
    var currency: String { get }
    var name: String { get }
    var exchange: String { get }
    var realExchange: RealExchange { get }
    var countryOfRisk: String { get }
    var countryOfRiskName: String { get }
    var tradingStatus: SecurityTradingStatus { get }
    var klong: Quotation? { get }
    var kshort: Quotation? { get }
    var dlong: Quotation? { get }
    var dshort: Quotation? { get }
    var dlongMin: Quotation? { get }
    var dshortMin: Quotation? { get }
    var first1minCandleDate: Date? { get }
    var first1dayCandleDate: Date? { get }
    var shortEnabledFlag: Bool { get }
    var otcFlag: Bool { get }
    var buyAvailableFlag: Bool { get }
    var sellAvailableFlag: Bool { get }
    var apiTradeAvailableFlag: Bool { get }
    var forIisFlag: Bool { get }
    var forQualInvestorFlag: Bool { get }
    var weekendFlag: Bool { get }
    var blockedTcaFlag: Bool { get }
    var minPriceIncrement: Quotation? { get }
}

extension Instrument: InstrumentProtocol {}
extension Share: InstrumentProtocol {}
extension Bond: InstrumentProtocol {}
extension Etf: InstrumentProtocol {}
extension Future: InstrumentProtocol {}
extension Option: InstrumentProtocol {}
extension Currency: InstrumentProtocol {}
