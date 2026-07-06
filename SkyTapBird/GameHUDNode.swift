//
//  GameHUDNode.swift
//  SkyTapBird
//

import SpriteKit

final class GameHUDNode: SKNode {
    private let titleLogoNode = SKSpriteNode(imageNamed: GameConfig.Artwork.titleLogo)
    private let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let bestLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")

    override init() {
        super.init()

        zPosition = 80

        titleLogoNode.texture?.filteringMode = .nearest
        titleLogoNode.size = CGSize(width: 216, height: 30)
        addChild(titleLogoNode)

        subtitleLabel.text = "Tap anywhere to start"
        subtitleLabel.fontSize = 20
        subtitleLabel.fontColor = SKColor(white: 1.0, alpha: 0.92)
        subtitleLabel.verticalAlignmentMode = .center
        addChild(subtitleLabel)

        scoreLabel.fontSize = 54
        scoreLabel.fontColor = .white
        scoreLabel.verticalAlignmentMode = .center
        addChild(scoreLabel)

        bestLabel.fontSize = 17
        bestLabel.fontColor = SKColor(white: 1.0, alpha: 0.92)
        bestLabel.horizontalAlignmentMode = .right
        bestLabel.verticalAlignmentMode = .center
        addChild(bestLabel)

        hintLabel.text = "One finger. One tap. Keep the bird alive."
        hintLabel.fontSize = 15
        hintLabel.fontColor = SKColor(white: 1.0, alpha: 0.88)
        hintLabel.verticalAlignmentMode = .center
        addChild(hintLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func update(score: Int, highScore: Int) {
        scoreLabel.text = "\(score)"
        bestLabel.text = "BEST \(highScore)"
    }

    func showReady() {
        titleLogoNode.alpha = 1
        subtitleLabel.alpha = 1
        hintLabel.alpha = 1
    }

    func showPlaying() {
        titleLogoNode.alpha = 0
        subtitleLabel.alpha = 0
        hintLabel.alpha = 0
    }

    func layout(
        in sceneSize: CGSize,
        safeAreaTop: CGFloat,
        groundHeight: CGFloat
    ) {
        let hudY = sceneSize.height - safeAreaTop - GameConfig.hudTopPadding

        titleLogoNode.position = CGPoint(
            x: sceneSize.width * 0.5,
            y: sceneSize.height * 0.72
        )
        subtitleLabel.position = CGPoint(
            x: sceneSize.width * 0.5,
            y: sceneSize.height * 0.64
        )
        scoreLabel.position = CGPoint(
            x: sceneSize.width * 0.5,
            y: hudY
        )
        bestLabel.position = CGPoint(
            x: sceneSize.width - GameConfig.sideInset,
            y: hudY + 4
        )
        hintLabel.position = CGPoint(
            x: sceneSize.width * 0.5,
            y: groundHeight + 38
        )
    }
}
