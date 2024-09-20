//
// PortfolioRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Запрос получения текущего портфеля по счёту. */

public struct PortfolioRequest: Encodable {
    public let accountId: String
    public let currency: CurrencyRequest

    public init(accountId: String, currency: CurrencyRequest = .rub) {
        self.accountId = accountId
        self.currency = currency
    }
}