//
//  SceneDelegate.swift
//  SkyTapBird
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = GameViewController()
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        gameViewController?.setGamePaused(false)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        gameViewController?.setGamePaused(true)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        gameViewController?.setGamePaused(true)
    }

    private var gameViewController: GameViewController? {
        window?.rootViewController as? GameViewController
    }
}
