import Foundation

typealias Handler = () -> Void

public extension Result {
    var failure: Failure? {
        switch self {
        case let .failure(failure): failure
        default: nil
        }
    }

    var success: Success? {
        switch self {
        case let .success(success): success
        default: nil
        }
    }
}

public extension Data {
    func decoded<T: Decodable>(as type: T.Type, using decoder: JSONDecoder) -> Result<T, Error> {
        Result { try decoder.decode(T.self, from: self) }
    }
}

public extension Date {
    func adding(_ value: Int, _ component: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }
}

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

public extension DispatchQueue {
    /// Safer version of `.main.sync` that prevents a potential deadlock.
    @discardableResult
    static func mainSync<T>(closure: () throws -> T) rethrows -> T {
        try Thread.isMainThread ? closure() : main.sync { try closure() }
    }
}

public extension NSLock {
    func read<T>(_ autoclosure: @autoclosure () -> T) -> T {
        withLock { autoclosure() }
    }
}
