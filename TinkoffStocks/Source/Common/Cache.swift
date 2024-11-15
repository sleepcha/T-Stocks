//
//  Cache.swift
//  T-Stocks
//
//  Created by sleepcha on 10/10/24.
//

import Foundation

final class Cache<Value> {
    final class CacheItem: NSDiscardableContent {
        let value: Value
        let expirationDate: Date

        init(_ value: Value, expiresOn date: Date) {
            self.value = value
            self.expirationDate = date
        }

        func beginContentAccess() -> Bool { true }
        func endContentAccess() {}
        func discardContentIfPossible() {}
        func isContentDiscarded() -> Bool { false }
    }

    private let cache: NSCache<NSString, CacheItem>
    private let now: DateProvider

    init(dateProvider: @escaping DateProvider, countLimit: Int = 0) {
        self.now = dateProvider
        self.cache = NSCache<NSString, CacheItem>()
        cache.countLimit = countLimit
    }

    func get(key: String) -> Value? {
        let key = key as NSString

        guard let item = cache.object(forKey: key) else {
            return nil
        }

        guard item.expirationDate > now() else {
            cache.removeObject(forKey: key)
            return nil
        }

        return item.value
    }

    func store(key: String, value: Value?, expiryDate: Date? = nil) {
        let key = key as NSString

        guard let value else {
            cache.removeObject(forKey: key)
            return
        }

        let item = CacheItem(value, expiresOn: expiryDate ?? .distantFuture)
        cache.setObject(item, forKey: key)
    }

    func empty() {
        cache.removeAllObjects()
    }
}
