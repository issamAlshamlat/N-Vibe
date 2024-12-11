//
//  SceneDelegate.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/9/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let navigationController = UINavigationController(rootViewController: MapViewController())
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

