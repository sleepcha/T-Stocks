import UIKit

// MARK: - InitConfigurable

protocol InitConfigurable {
    init()
}

extension InitConfigurable {
    init(configure: (Self) -> Void) {
        self.init()
        configure(self)
    }
}

extension UIResponder: InitConfigurable {}
