import Foundation

typealias VoidHandler = () -> Void
typealias Handler<T> = (T) -> Void
typealias DateProvider = () -> Date

public extension Result {
    var failure: Failure? {
        guard case .failure(let failure) = self else { return nil }
        return failure
    }

    var success: Success? {
        guard case .success(let success) = self else { return nil }
        return success
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

public extension NSLock {
    func read<T>(_ autoclosure: @autoclosure () -> T) -> T {
        withLock { autoclosure() }
    }
}

public extension String {
    static let spaceSymbol: String = " "
}
