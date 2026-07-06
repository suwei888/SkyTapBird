//
//  GameOverPanelNode.swift
//  SkyTapBird
//

import SpriteKit

final class GameOverPanelNode: SKNode {
    private let panelNode = SKSpriteNode(imageNamed: GameConfig.Artwork.gameOverPanel)
    private let restartButtonNode = SKSpriteNode(imageNamed: GameConfig.Artwork.restartButton)
    private let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let bodyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")

    override init() {
        super.init()

        zPosition = 90
        isHidden = true

        panelNode.texture?.filteringMode = .nearest
        panelNode.size = CGSize(width: 256, height: 160)
        addChild(panelNode)

        restartButtonNode.texture?.filteringMode = .nearest
        restartButtonNode.size = CGSize(width: 128, height: 48)
        restartButtonNode.position = CGPoint(x: 0, y: -43)
        restartButtonNode.zPosition = 1
        panelNode.addChild(restartButtonNode)

        titleLabel.text = "Crash"
        titleLabel.fontSize = 30
        titleLabel.fontColor = SKColor(red: 0.35, green: 0.24, blue: 0.16, alpha: 1.0)
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 45)
        titleLabel.zPosition = 2
        panelNode.addChild(titleLabel)

        bodyLabel.fontSize = 18
        bodyLabel.fontColor = SKColor(red: 0.33, green: 0.24, blue: 0.18, alpha: 0.94)
        bodyLabel.verticalAlignmentMode = .center
        bodyLabel.numberOfLines = 2
        bodyLabel.preferredMaxLayoutWidth = 180
        bodyLabel.position = CGPoint(x: 0, y: 5)
        bodyLabel.zPosition = 2
        panelNode.addChild(bodyLabel)

        hintLabel.text = "Tap anywhere to retry"
        hintLabel.fontSize = 15
        hintLabel.fontColor = SKColor(red: 0.33, green: 0.24, blue: 0.18, alpha: 0.82)
        hintLabel.verticalAlignmentMode = .center
        hintLabel.position = CGPoint(x: 0, y: -68)
        hintLabel.zPosition = 2
        panelNode.addChild(hintLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func show(score: Int, highScore: Int) {
        bodyLabel.text = "Score \(score)\nBest \(highScore)"
        hintLabel.alpha = 0.45
        isHidden = false
    }

    func hide() {
        isHidden = true
        hintLabel.alpha = 1
    }

    func updateRestartAvailability(_ isAvailable: Bool) {
        hintLabel.alpha = isAvailable ? 1 : 0.45
    }

    func layout(in sceneSize: CGSize) {
        position = CGPoint(
            x: sceneSize.width * 0.5,
            y: sceneSize.height * 0.56
        )
    }
}
