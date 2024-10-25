import Foundation

typealias VoidHandler = () -> Void
typealias Handler<T> = (T) -> Void

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

public extension NSLock {
    func read<T>(_ autoclosure: @autoclosure () -> T) -> T {
        withLock { autoclosure() }
    }
}

public extension String {
    static let spaceSymbol: String = " "
}
