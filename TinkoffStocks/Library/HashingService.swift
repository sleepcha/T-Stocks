//
//  HashingService.swift
//  TinkoffStocks
//
//  Created by sleepcha on 8/25/23.
//

import CryptoKit
import Foundation

enum HashingService {
    enum HashAlgorithm {
        case sha1
        case md5
        case sha256
        case sha384
        case sha512

        var instance: any HashFunction.Type {
            switch self {
            case .sha1: Insecure.SHA1.self
            case .md5: Insecure.MD5.self
            case .sha256: SHA256.self
            case .sha384: SHA384.self
            case .sha512: SHA512.self
            }
        }
    }

    static func getDigest(of text: String, using algorithm: HashAlgorithm) -> String {
        getDigest(of: Data(text.utf8), using: algorithm)
    }

    static func getDigest(of data: Data, using algorithm: HashAlgorithm) -> String {
        algorithm.instance
            .hash(data: data)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
