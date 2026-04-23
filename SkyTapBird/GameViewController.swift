//
//  GameViewController.swift
//  SkyTapBird
//
//  Created by SkyTapBird contributors.
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {

    override func loadView() {
        view = SKView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else {
            assertionFailure("Expected root view to be an SKView.")
            return
        }

        let scene = GameScene(size: GameConfig.logicalSize)
        scene.scaleMode = .aspectFill

        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 60
        skView.showsFPS = false
        skView.showsNodeCount = false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
