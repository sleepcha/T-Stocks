//
//  Dialog+UIAlertController.swift
//  T-Stocks
//
//  Created by sleepcha on 7/12/24.
//

import UIKit

extension Dialog {
    func make(_ style: UIAlertController.Style) -> UIAlertController {
        let alert = UIAlertController(title: title, message: text, preferredStyle: style)

        actions
            .map { action in
                UIAlertAction(
                    title: action.title,
                    style: action.kind.asAlertActionStyle,
                    handler: { _ in action.handler() }
                )
            }
            .forEach(alert.addAction)

        return alert
    }
}

private extension Dialog.Action.Kind {
    var asAlertActionStyle: UIAlertAction.Style {
        switch self {
        case .primary: .default
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}
