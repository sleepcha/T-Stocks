//
//  JSONCoders.swift
//  T-Stocks
//
//  Created by sleepcha on 8/17/24.
//

import Foundation

extension JSONEncoder {
    static let custom: JSONEncoder = {
        let encoder = JSONEncoder()
        // creates a consistent caching key from the request body
        encoder.outputFormatting = .sortedKeys
        encoder.dateEncodingStrategy = .iso8601
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        return encoder
    }()
}

extension JSONDecoder {
    static let custom: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithOptionalFractionalSeconds
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        return decoder
    }()
}

private extension JSONDecoder.DateDecodingStrategy {
    static let iso8601WithOptionalFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)

        let formatter = ISO8601DateFormatter()
        if string.contains(".") { formatter.formatOptions.insert(.withFractionalSeconds) }

        guard let date = formatter.date(from: string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(string)"
            )
        }
        return date
    }
}
