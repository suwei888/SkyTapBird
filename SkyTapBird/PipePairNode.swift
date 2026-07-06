//
//  PipePairNode.swift
//  SkyTapBird
//

import SpriteKit

final class PipePairNode: SKNode {
    init(
        layout: PipeLayout,
        playfield: ClosedRange<CGFloat>,
        sequence: Int,
        sceneWidth: CGFloat
    ) {
        super.init()

        name = GameConfig.NodeName.pipePair
        zPosition = 30
        position = CGPoint(x: sceneWidth + GameConfig.pipeWidth, y: 0)

        let topPipe = Self.makePipe(
            height: layout.topPipeHeight,
            imageName: GameConfig.Artwork.pipeTop
        )
        topPipe.position = CGPoint(
            x: 0,
            y: layout.gapTop + layout.topPipeHeight * 0.5
        )
        addChild(topPipe)

        let bottomPipe = Self.makePipe(
            height: layout.bottomPipeHeight,
            imageName: GameConfig.Artwork.pipeBottom
        )
        bottomPipe.position = CGPoint(
            x: 0,
            y: playfield.lowerBound + layout.bottomPipeHeight * 0.5
        )
        addChild(bottomPipe)

        let scoreNode = SKNode()
        scoreNode.name = "\(GameConfig.NodeName.scorePrefix)\(sequence)"
        scoreNode.position = CGPoint(
            x: GameConfig.pipeWidth * 0.5,
            y: (playfield.lowerBound + playfield.upperBound) * 0.5
        )

        let scoreBody = SKPhysicsBody(
            rectangleOf: CGSize(
                width: 12,
                height: playfield.upperBound - playfield.lowerBound
            )
        )
        scoreBody.isDynamic = false
        scoreBody.categoryBitMask = GameConfig.PhysicsCategory.score
        scoreBody.contactTestBitMask = GameConfig.PhysicsCategory.bird
        scoreBody.collisionBitMask = 0
        scoreNode.physicsBody = scoreBody
        addChild(scoreNode)

        let travelDistance = sceneWidth + GameConfig.pipeWidth * 3
        let moveAction = SKAction.moveBy(
            x: -travelDistance,
            y: 0,
            duration: GameConfig.pipeTravelDuration
        )
        run(.sequence([moveAction, .removeFromParent()]))
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func freeze() {
        removeAllActions()
    }

    private static func makePipe(height: CGFloat, imageName: String) -> SKSpriteNode {
        let pipe = SKSpriteNode(imageNamed: imageName)
        pipe.texture?.filteringMode = .nearest
        pipe.size = CGSize(width: GameConfig.pipeWidth, height: height)

        let body = SKPhysicsBody(
            rectangleOf: CGSize(
                width: GameConfig.pipeWidth - 10,
                height: height
            )
        )
        body.isDynamic = false
        body.categoryBitMask = GameConfig.PhysicsCategory.world
        body.contactTestBitMask = GameConfig.PhysicsCategory.bird
        body.collisionBitMask = GameConfig.PhysicsCategory.bird
        pipe.physicsBody = body

        return pipe
    }
}
