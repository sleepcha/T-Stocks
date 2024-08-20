//
//  Dialog+UIAlertController.swift
//  T-Stocks
//
//  Created by sleepcha on 7/12/24.
//

import UIKit

extension Dialog {
    func make(_ style: UIAlertController.Style) -> UIAlertController {
        let actionSheet = UIAlertController(title: title, message: text, preferredStyle: style)
        let actions = actions.map { action in
            UIAlertAction(
                title: action.title,
                style: action.kind.asAlertActionStyle,
                handler: { _ in action.handler() }
            )
        }

        actions.forEach(actionSheet.addAction)
        return actionSheet
    }
}

extension Dialog.Action.Kind {
    var asAlertActionStyle: UIAlertAction.Style {
        switch self {
        case .primary: .default
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}
