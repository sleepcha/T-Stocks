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

    func configuring(_ configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}

extension NSObject: InitConfigurable {}
