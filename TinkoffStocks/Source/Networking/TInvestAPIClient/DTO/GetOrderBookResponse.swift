//
// GetOrderBookResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Информация о стакане. */

public struct GetOrderBookResponse: Decodable {
    /** Uid инструмента. */
    public let instrumentUid: String
    /** Figi-идентификатор инструмента. */
    public let figi: String
    /** Глубина стакана. */
    public let depth: Int
    /** Множество пар значений на покупку. */
    public let bids: [Order]
    /** Множество пар значений на продажу. */
    public let asks: [Order]
    public let lastPrice: Quotation
    public let closePrice: Quotation
    public let limitUp: Quotation
    public let limitDown: Quotation

    /** Время получения цены последней сделки. */
    public let lastPriceTs: Date?
    /** Время получения цены закрытия. */
    public let closePriceTs: Date?
    /** Время формирования стакана на бирже. */
    public let orderbookTs: Date?
}
