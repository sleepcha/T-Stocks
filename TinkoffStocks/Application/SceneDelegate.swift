//
//  SceneDelegate.swift
//  TinkoffStocks
//
//  Created by sleepcha on 8/23/23.
//  
//
    

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.backgroundColor = .systemBackground
        
        let firstScreenVC = ViewController()
        firstScreenVC.view.backgroundColor = .systemYellow
        window?.rootViewController = UINavigationController(rootViewController: firstScreenVC)
        window?.makeKeyAndVisible()
    }
}
