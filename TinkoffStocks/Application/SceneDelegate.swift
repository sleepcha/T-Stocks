//
//  SceneDelegate.swift
//  TinkoffStocks
//
//  Created by sleepcha on 8/23/23.
//
//

import UIKit

// MARK: - SceneDelegate

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var appFlow: AppFlow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        appFlow = AppFlow(windowScene: windowScene)
        appFlow?.start()
    }
}
