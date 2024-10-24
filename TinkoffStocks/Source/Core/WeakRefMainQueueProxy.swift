import Foundation

/// Extend to conform to your View protocol by wrapping each method call in `dispatch(_:)`.
final class WeakRefMainQueueProxy<View: AnyObject> {
    private weak var view: View?

    init(_ view: View) {
        self.view = view
    }

    func dispatch(_ completion: (View) -> Void) {
        guard let view else { return }
        DispatchQueue.mainSync { completion(view) }
    }
}
