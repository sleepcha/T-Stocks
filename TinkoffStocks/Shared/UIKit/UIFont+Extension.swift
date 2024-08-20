import UIKit

extension UIFont {
    func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }

    func bold() -> UIFont {
        with(traits: .traitBold)
    }

    func italic() -> UIFont {
        with(traits: .traitItalic)
    }
}
