//
// GetOrdersResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Список активных торговых поручений. */

public struct GetOrdersResponse: Decodable {
    public let orders: [OrderState]
}