//
// OrderStage.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Сделки в рамках торгового поручения. */

public struct OrderStage: Decodable {
    public let price: MoneyValue
    public let quantity: String
    public let tradeId: String
}