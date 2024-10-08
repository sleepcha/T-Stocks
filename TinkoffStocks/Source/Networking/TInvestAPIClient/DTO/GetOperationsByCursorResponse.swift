//
// GetOperationsByCursorResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Список операций по счёту с пагинацией. */

public struct GetOperationsByCursorResponse: Decodable {
    public let hasNext: Bool
    public let nextCursor: String
    public let items: [OperationItem]
}
