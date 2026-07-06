//
//  BirdNode.swift
//  SkyTapBird
//

import SpriteKit

final class BirdNode: SKNode {
    private let spriteNode: SKSpriteNode
    private let flapTextures: [SKTexture]
    private let hitTexture: SKTexture

    override init() {
        flapTextures = GameConfig.Artwork.birdFlapFrames.map { Self.makePixelTexture(named: $0) }
        hitTexture = Self.makePixelTexture(named: GameConfig.Artwork.birdHit)
        spriteNode = SKSpriteNode(texture: flapTextures.first)

        super.init()

        name = "bird"
        zPosition = 40

        spriteNode.size = GameConfig.birdSize
        addChild(spriteNode)

        let body = SKPhysicsBody(circleOfRadius: 12)
        body.categoryBitMask = GameConfig.PhysicsCategory.bird
        body.collisionBitMask = GameConfig.PhysicsCategory.world
        body.contactTestBitMask = GameConfig.PhysicsCategory.world | GameConfig.PhysicsCategory.score
        body.usesPreciseCollisionDetection = true
        body.allowsRotation = false
        body.isDynamic = false
        body.affectedByGravity = false
        body.linearDamping = 0.08
        physicsBody = body

        startFlapAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func reset(at startPoint: CGPoint) {
        position = startPoint
        zRotation = 0

        removeAllActions()
        spriteNode.removeAllActions()
        spriteNode.texture = flapTextures.first
        startFlapAnimation()

        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.velocity = .zero

        let hoverUp = SKAction.moveBy(
            x: 0,
            y: GameConfig.birdHoverDistance,
            duration: 0.7
        )
        hoverUp.timingMode = .easeInEaseOut
        let hoverLoop = SKAction.repeatForever(.sequence([hoverUp, hoverUp.reversed()]))
        run(hoverLoop, withKey: GameConfig.ActionKey.birdHover)
    }

    func startPlaying() {
        removeAction(forKey: GameConfig.ActionKey.birdHover)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
    }

    func flap() {
        physicsBody?.velocity = CGVector(dx: 0, dy: GameConfig.birdFlapVelocity)
        zRotation = 0.35
    }

    func crash() {
        removeAction(forKey: GameConfig.ActionKey.birdHover)
        spriteNode.removeAction(forKey: GameConfig.ActionKey.birdFlap)
        spriteNode.texture = hitTexture

        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.velocity = .zero
        zRotation = -0.85
    }

    func updateRotation() {
        guard let body = physicsBody else { return }

        if body.velocity.dy < GameConfig.birdMaxFallVelocity {
            body.velocity.dy = GameConfig.birdMaxFallVelocity
        }

        let normalizedLift = max(
            -1.0,
            min(1.0, body.velocity.dy / GameConfig.birdFlapVelocity)
        )
        zRotation = normalizedLift * 0.55
    }

    private func startFlapAnimation() {
        guard !flapTextures.isEmpty else { return }

        let action = SKAction.animate(
            with: flapTextures,
            timePerFrame: 0.08,
            resize: false,
            restore: false
        )
        spriteNode.run(
            .repeatForever(action),
            withKey: GameConfig.ActionKey.birdFlap
        )
    }

    private static func makePixelTexture(named name: String) -> SKTexture {
        let texture = SKTexture(imageNamed: name)
        texture.filteringMode = .nearest
        return texture
    }
}
