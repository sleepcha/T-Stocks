//
//  Cache.swift
//  T-Stocks
//
//  Created by sleepcha on 10/10/24.
//

import Foundation

final class Cache<Value> {
    final class CacheItem {
        let value: Value
        let expirationDate: Date

        init(_ value: Value, expiresOn date: Date) {
            self.value = value
            self.expirationDate = date
        }
    }

    private let cache = NSCache<NSString, CacheItem>()

    init(countLimit: Int = 0) {
        cache.countLimit = countLimit
    }

    /// `expiry` parameter is only used in the setter.
    subscript(key: String, expiry expiry: Date? = nil) -> Value? {
        get {
            let key = key as NSString

            guard let item = cache.object(forKey: key) else {
                return nil
            }

            guard item.expirationDate > .now else {
                cache.removeObject(forKey: key)
                return nil
            }

            return item.value
        }
        set {
            let key = key as NSString

            guard let newValue else {
                cache.removeObject(forKey: key)
                return
            }

            let item = CacheItem(newValue, expiresOn: expiry ?? .distantFuture)
            cache.setObject(item, forKey: key)
        }
    }

    func empty() {
        cache.removeAllObjects()
    }
}
