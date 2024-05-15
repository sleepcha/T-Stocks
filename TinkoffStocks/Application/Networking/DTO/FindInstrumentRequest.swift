//
// FindInstrumentRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Запрос на поиск инструментов. */

public struct FindInstrumentRequest: Codable {
    public let query: String
    public let instrumentKind: InstrumentType?

    /// Фильтр для отображения только торговых инструментов.
    public let apiTradeAvailableFlag: Bool

    public init(query: String, instrumentKind: InstrumentType? = nil, apiTradeAvailableFlag: Bool = true) {
        self.query = query
        self.instrumentKind = instrumentKind
        self.apiTradeAvailableFlag = apiTradeAvailableFlag
    }
}
