//
//  GameViewController.swift
//  SkyTapBird
//

import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    private var gameScene: GameScene?

    override func loadView() {
        view = SKView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else {
            assertionFailure("Expected root view to be an SKView.")
            return
        }

        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 60
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.isAccessibilityElement = true
        skView.accessibilityIdentifier = "gameView"
        skView.accessibilityLabel = "Sky Tap Bird game"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard
            let skView = view as? SKView,
            skView.bounds.width > 0,
            skView.bounds.height > 0
        else {
            return
        }

        if let gameScene {
            if gameScene.size != skView.bounds.size {
                gameScene.size = skView.bounds.size
            }
        } else {
            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)
            gameScene = scene
        }

        gameScene?.updateSafeArea(top: view.safeAreaInsets.top)
    }

    func setGamePaused(_ paused: Bool) {
        guard let skView = view as? SKView else { return }

        gameScene?.setApplicationPaused(paused)
        skView.isPaused = paused
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var shouldAutorotate: Bool {
        false
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        .bottom
    }
}
