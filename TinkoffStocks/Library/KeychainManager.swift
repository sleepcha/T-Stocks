//
//  KeychainManager.swift
//  TinkoffStocks
//
//  Created by sleepcha on 12/19/22.
//

import Foundation

// MARK: - IKeychainManager

protocol IKeychainManager {
    func save<T: Encodable>(_ serviceName: String, data: T, completion: @escaping (Error?) -> Void)
    func read<T: Decodable>(_ serviceName: String, type: T.Type, completion: @escaping (Result<T, Error>) -> Void)
    func delete(_ serviceName: String, completion: @escaping (Error?) -> Void)
}

// MARK: - KeychainManager

final class KeychainManager: IKeychainManager {
    private let account: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(account: String, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
        self.account = account
        self.encoder = encoder
        self.decoder = decoder
    }

    func save(_ serviceName: String, data: some Encodable, completion: @escaping (Error?) -> Void) {
        DispatchQueue.global().async { [self] in
            let jsonData: Data

            do {
                jsonData = try encoder.encode(data)
            } catch {
                completion(error)
                return
            }

            let accessControl = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                .userPresence,
                nil
            )!

            var query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccessControl: accessControl,
                kSecAttrAccount: account,
                kSecAttrService: serviceName,
                kSecValueData: jsonData,
            ]

            var status = SecItemAdd(query as CFDictionary, nil)

            // update the item if it already exists
            if status == errSecDuplicateItem {
                query.removeValue(forKey: kSecValueData)
                let attributesToUpdate = [kSecValueData: jsonData]
                status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            }

            completion(status.asNSError)
        }
    }

    func read<T: Decodable>(_ serviceName: String, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.global().async { [self] in
            let accessControl = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                .userPresence,
                nil
            )!

            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccessControl: accessControl,
                kSecAttrAccount: account,
                kSecAttrService: serviceName,
                kSecReturnData: true,
            ]

            var buffer: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &buffer)

            if let error = status.asNSError {
                completion(.failure(error))
                return
            }

            let jsonData = buffer as? Data ?? Data()
            let result = Result { try decoder.decode(T.self, from: jsonData) }

            completion(result)
        }
    }

    func delete(_ serviceName: String, completion: @escaping (Error?) -> Void) {
        DispatchQueue.global().async { [self] in
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account,
                kSecAttrService: serviceName,
            ]

            let status = SecItemDelete(query as CFDictionary)
            completion(status.asNSError)
        }
    }
}

extension OSStatus {
    var asNSError: NSError? {
        guard self != errSecSuccess else { return nil }
        return NSError(domain: NSOSStatusErrorDomain, code: Int(self))
    }
}
