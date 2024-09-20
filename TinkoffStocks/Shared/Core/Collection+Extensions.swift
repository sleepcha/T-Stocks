//
//  Collection+Extensions.swift
//  T-Stocks
//
//  Created by sleepcha on 9/14/24.
//

import Foundation

public extension Collection {
    /// Applies a closure to the collection and returns the result.
    func apply<T>(_ transform: (Self) -> T) -> T {
        transform(self)
    }

    /// Converts a collection into a dictionary using specified key paths for the dictionary keys and values.
    ///
    /// Make sure that the property representing the key is unique (like UUID) to avoid overlapping keys.
    ///
    /// Example:
    /// ```swift
    /// struct Person {
    ///     let id: Int
    ///     let name: String
    ///     let age: Int
    /// }
    ///
    /// let people = [
    ///     Person(id: 1, name: "Alice", age: 30),
    ///     Person(id: 2, name: "Bob", age: 25),
    ///     Person(id: 3, name: "Charlie", age: 35)
    /// ]
    ///
    /// let nameDictionary = people.reduceToDictionary(key: \.id, value: \.name)
    /// // nameDictionary: [1: "Alice", 2: "Bob", 3: "Charlie"]
    ///
    /// let ageDictionary = people.reduceToDictionary(key: \.id, value: \.age)
    /// // ageDictionary: [1: 30, 2: 25, 3: 35]
    /// ```
    func reduceToDictionary<Key: Hashable, Value>(
        key: KeyPath<Element, Key>,
        value: KeyPath<Element, Value>
    ) -> [Key: Value] {
        reduce(into: [:]) { dict, element in
            dict[element[keyPath: key]] = element[keyPath: value]
        }
    }

    /// A version of ``reduceToDictionary(key:value:)``  with optional value.
    func reduceToDictionary<Key: Hashable, Value>(
        key: KeyPath<Element, Key>,
        optionalValue: KeyPath<Element, Value?>
    ) -> [Key: Value] {
        reduce(into: [:]) { dict, element in
            guard let value = element[keyPath: optionalValue] else { return }
            dict[element[keyPath: key]] = value
        }
    }
}
