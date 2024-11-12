import Foundation

/// Extend to conform to your View protocol by wrapping each method call in `dispatch(_:)`.
final class WeakRefMainQueueProxy<Subject: AnyObject> {
    private weak var view: Subject?

    init(_ view: Subject) {
        self.view = view
    }

    func dispatch(_ completion: (Subject) -> Void) {
        guard let view else { return }
        DispatchQueue.mainSync { completion(view) }
    }
}
