//
//  CachedURLResponse+Extension.swift
//  T-Stocks
//
//  Created by sleepcha on 8/10/24.
//

import Foundation

extension CachedURLResponse {
    private static let timestampKey = "cacheEntryTimestamp"

    var timestamp: Date? { userInfo?[Self.timestampKey] as? Date }

    func addingTimestamp(_ date: Date) -> CachedURLResponse {
        var newUserInfo = userInfo ?? [:]
        newUserInfo[Self.timestampKey] = date

        return CachedURLResponse(
            response: response,
            data: data,
            userInfo: newUserInfo,
            storagePolicy: storagePolicy
        )
    }
}
