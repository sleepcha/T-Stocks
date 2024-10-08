//
// InstrumentRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

/** Запрос получения инструмента по идентификатору. */

public struct InstrumentRequest: Encodable {
    public let id: String
    public let idType: InstrumentIdType
    public let classCode: String?

    public init(id: String, idType: InstrumentIdType, classCode: String? = nil) {
        self.id = id
        self.idType = idType
        self.classCode = classCode
    }
}
