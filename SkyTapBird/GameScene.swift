//
//  GameScene.swift
//  SkyTapBird
//
//  Created by SkyTapBird contributors.
//

import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private enum SceneState: Equatable {
        case ready
        case playing
        case gameOver(restartAvailableAt: TimeInterval)
    }

    private let titleLogoNode = SKSpriteNode(imageNamed: GameConfig.Artwork.titleLogo)
    private let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let bestLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")

    private let resultPanel = SKSpriteNode(imageNamed: GameConfig.Artwork.gameOverPanel)
    private let restartButtonNode = SKSpriteNode(imageNamed: GameConfig.Artwork.restartButton)
    private let resultTitleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let resultBodyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let resultHintLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")

    private let backgroundNode = SKSpriteNode(imageNamed: GameConfig.Artwork.backgroundDay)
    private let sunNode = SKSpriteNode(imageNamed: GameConfig.Artwork.sun)
    private let smallCloudNode = SKSpriteNode(imageNamed: GameConfig.Artwork.cloudSmall)
    private let largeCloudNode = SKSpriteNode(imageNamed: GameConfig.Artwork.cloudLarge)
    private let groundNode = SKSpriteNode(imageNamed: GameConfig.Artwork.groundStrip)
    private let birdNode = SKSpriteNode(imageNamed: GameConfig.Artwork.birdFlapFrames[0])
    private let birdShadowNode = SKShapeNode(ellipseOf: CGSize(width: 52, height: 14))
    private lazy var birdFlapTextures = Self.makePixelTextures(named: GameConfig.Artwork.birdFlapFrames)
    private lazy var birdHitTexture = Self.makePixelTexture(named: GameConfig.Artwork.birdHit)

    private var state: SceneState = .ready
    private var score = 0 {
        didSet { scoreLabel.text = "\(score)" }
    }
    private var highScore = UserDefaults.standard.integer(forKey: GameConfig.StorageKey.highScore) {
        didSet { bestLabel.text = "BEST \(highScore)" }
    }
    private var nextPipeSpawnTime: TimeInterval?
    private var currentSceneTime: TimeInterval = 0
    private var pipeSequence = 0
    private var hasCompletedInitialSetup = false

    private let scoreFeedback = UIImpactFeedbackGenerator(style: .light)
    private let failFeedback = UINotificationFeedbackGenerator()

    private static func makePixelTexture(named name: String) -> SKTexture {
        let texture = SKTexture(imageNamed: name)
        texture.filteringMode = .nearest
        return texture
    }

    private static func makePixelTextures(named names: [String]) -> [SKTexture] {
        names.map { makePixelTexture(named: $0) }
    }

    override func didMove(to view: SKView) {
        guard !hasCompletedInitialSetup else { return }
        hasCompletedInitialSetup = true

        backgroundColor = SKColor(red: 0.56, green: 0.83, blue: 0.98, alpha: 1.0)
        physicsWorld.gravity = CGVector(dx: 0, dy: -18.0)
        physicsWorld.contactDelegate = self

        scoreFeedback.prepare()
        failFeedback.prepare()

        configureBackdrop()
        configureGround()
        configureBird()
        configureLabels()
        configureResultPanel()
        layoutScene()
        enterReadyState()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutScene()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !touches.isEmpty else { return }

        switch state {
        case .ready:
            startRun()
            flapBird()
        case .playing:
            flapBird()
        case let .gameOver(restartAvailableAt):
            guard currentSceneTime >= restartAvailableAt else { return }
            enterReadyState()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        switch state {
        case .ready:
            break
        case .playing:
            updateBirdRotation()
            spawnPipesIfNeeded(at: currentTime)
        case let .gameOver(restartAvailableAt):
            resultHintLabel.alpha = currentTime >= restartAvailableAt ? 1.0 : 0.45
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let birdMask = GameConfig.PhysicsCategory.bird
        let scoreMask = GameConfig.PhysicsCategory.score

        let firstCategory = contact.bodyA.categoryBitMask
        let secondCategory = contact.bodyB.categoryBitMask
        let pairMask = firstCategory | secondCategory

        guard pairMask & birdMask != 0 else { return }

        if pairMask & scoreMask != 0 {
            handleScore(contact: contact)
            return
        }

        handleCollision()
    }

    private func configureBackdrop() {
        backgroundNode.texture?.filteringMode = .nearest
        backgroundNode.zPosition = -60
        addChild(backgroundNode)

        sunNode.texture?.filteringMode = .nearest
        sunNode.zPosition = -45
        addChild(sunNode)

        smallCloudNode.texture?.filteringMode = .nearest
        smallCloudNode.zPosition = -40
        addChild(smallCloudNode)

        largeCloudNode.texture?.filteringMode = .nearest
        largeCloudNode.zPosition = -40
        addChild(largeCloudNode)
    }

    private func configureGround() {
        groundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        groundNode.texture?.filteringMode = .nearest
        groundNode.zPosition = 20
        groundNode.size = CGSize(width: 520, height: GameConfig.groundHeight)
        groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
        groundNode.physicsBody?.isDynamic = false
        groundNode.physicsBody?.categoryBitMask = GameConfig.PhysicsCategory.world
        groundNode.physicsBody?.contactTestBitMask = GameConfig.PhysicsCategory.bird
        groundNode.physicsBody?.collisionBitMask = GameConfig.PhysicsCategory.bird
        addChild(groundNode)
    }

    private func configureBird() {
        birdNode.name = "bird"
        birdNode.texture?.filteringMode = .nearest
        birdNode.size = GameConfig.birdSize
        birdNode.zPosition = 40
        birdNode.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        birdNode.physicsBody?.categoryBitMask = GameConfig.PhysicsCategory.bird
        birdNode.physicsBody?.collisionBitMask = GameConfig.PhysicsCategory.world
        birdNode.physicsBody?.contactTestBitMask = GameConfig.PhysicsCategory.world | GameConfig.PhysicsCategory.score
        birdNode.physicsBody?.usesPreciseCollisionDetection = true
        birdNode.physicsBody?.allowsRotation = false
        birdNode.physicsBody?.isDynamic = false
        birdNode.physicsBody?.affectedByGravity = false
        birdNode.physicsBody?.linearDamping = 0.08
        addChild(birdNode)
        runBirdFlapAnimation()

        birdShadowNode.fillColor = SKColor(white: 0.0, alpha: 0.12)
        birdShadowNode.strokeColor = .clear
        birdShadowNode.zPosition = 10
        addChild(birdShadowNode)
    }

    private func configureLabels() {
        titleLogoNode.texture?.filteringMode = .nearest
        titleLogoNode.size = CGSize(width: 216, height: 30)
        titleLogoNode.zPosition = 80
        addChild(titleLogoNode)

        subtitleLabel.text = "Tap anywhere to start"
        subtitleLabel.fontSize = 20
        subtitleLabel.fontColor = SKColor(white: 1.0, alpha: 0.92)
        subtitleLabel.verticalAlignmentMode = .center
        addChild(subtitleLabel)

        scoreLabel.text = "0"
        scoreLabel.fontSize = 54
        scoreLabel.fontColor = .white
        scoreLabel.verticalAlignmentMode = .center
        addChild(scoreLabel)

        bestLabel.text = "BEST \(highScore)"
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

    private func configureResultPanel() {
        resultPanel.texture?.filteringMode = .nearest
        resultPanel.size = CGSize(width: 256, height: 160)
        resultPanel.zPosition = 90
        addChild(resultPanel)

        restartButtonNode.texture?.filteringMode = .nearest
        restartButtonNode.size = CGSize(width: 128, height: 48)
        restartButtonNode.zPosition = 1
        resultPanel.addChild(restartButtonNode)

        resultTitleLabel.fontSize = 30
        resultTitleLabel.fontColor = SKColor(red: 0.35, green: 0.24, blue: 0.16, alpha: 1.0)
        resultTitleLabel.verticalAlignmentMode = .center
        resultTitleLabel.text = "Crash"
        resultTitleLabel.zPosition = 2
        resultPanel.addChild(resultTitleLabel)

        resultBodyLabel.fontSize = 18
        resultBodyLabel.fontColor = SKColor(red: 0.33, green: 0.24, blue: 0.18, alpha: 0.94)
        resultBodyLabel.verticalAlignmentMode = .center
        resultBodyLabel.numberOfLines = 2
        resultBodyLabel.preferredMaxLayoutWidth = 180
        resultBodyLabel.text = "Score 0\nBest 0"
        resultBodyLabel.zPosition = 2
        resultPanel.addChild(resultBodyLabel)

        resultHintLabel.fontSize = 15
        resultHintLabel.fontColor = SKColor(red: 0.33, green: 0.24, blue: 0.18, alpha: 0.82)
        resultHintLabel.verticalAlignmentMode = .center
        resultHintLabel.text = "Tap anywhere to retry"
        resultHintLabel.zPosition = 2
        resultPanel.addChild(resultHintLabel)
    }

    private func resizeSprite(_ sprite: SKSpriteNode, toFill targetSize: CGSize) {
        guard let textureSize = sprite.texture?.size(), textureSize.width > 0, textureSize.height > 0 else {
            sprite.size = targetSize
            return
        }

        let scale = max(targetSize.width / textureSize.width, targetSize.height / textureSize.height)
        sprite.size = CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
    }

    private func layoutScene() {
        resizeSprite(backgroundNode, toFill: size)
        backgroundNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)

        sunNode.size = CGSize(width: 58, height: 58)
        sunNode.position = CGPoint(x: size.width * 0.77, y: size.height * 0.82)

        smallCloudNode.size = CGSize(width: 80, height: 40)
        smallCloudNode.position = CGPoint(x: size.width * 0.24, y: size.height * 0.82)

        largeCloudNode.size = CGSize(width: 108, height: 49)
        largeCloudNode.position = CGPoint(x: size.width * 0.66, y: size.height * 0.68)

        groundNode.size = CGSize(width: size.width + 80, height: GameConfig.groundHeight)
        groundNode.position = CGPoint(x: size.width * 0.5, y: GameConfig.groundHeight * 0.5)
        groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
        groundNode.physicsBody?.isDynamic = false
        groundNode.physicsBody?.categoryBitMask = GameConfig.PhysicsCategory.world
        groundNode.physicsBody?.contactTestBitMask = GameConfig.PhysicsCategory.bird
        groundNode.physicsBody?.collisionBitMask = GameConfig.PhysicsCategory.bird

        birdShadowNode.position = CGPoint(x: GameConfig.birdStartPoint.x, y: GameConfig.groundHeight + 24)

        titleLogoNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.72)
        subtitleLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.64)
        scoreLabel.position = CGPoint(x: size.width * 0.5, y: size.height - GameConfig.hudTopInset)
        bestLabel.position = CGPoint(x: size.width - GameConfig.sideInset, y: size.height - GameConfig.hudTopInset + 4)
        hintLabel.position = CGPoint(x: size.width * 0.5, y: GameConfig.groundHeight + 38)

        resultPanel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.56)
        resultTitleLabel.position = CGPoint(x: 0, y: 45)
        resultBodyLabel.position = CGPoint(x: 0, y: 5)
        restartButtonNode.position = CGPoint(x: 0, y: -43)
        resultHintLabel.position = CGPoint(x: 0, y: -68)
    }

    private func enterReadyState() {
        state = .ready
        score = 0
        nextPipeSpawnTime = nil
        pipeSequence = 0

        removeActivePipePairs()
        resetBirdForReadyState()

        titleLogoNode.alpha = 1.0
        subtitleLabel.alpha = 1.0
        hintLabel.alpha = 1.0
        resultPanel.isHidden = true
        resultHintLabel.alpha = 1.0
    }

    private func startRun() {
        guard state == .ready else { return }
        state = .playing
        nextPipeSpawnTime = nil

        titleLogoNode.alpha = 0.0
        subtitleLabel.alpha = 0.0
        hintLabel.alpha = 0.0
        resultPanel.isHidden = true

        birdNode.removeAction(forKey: "hover")
        birdNode.physicsBody?.isDynamic = true
        birdNode.physicsBody?.affectedByGravity = true
    }

    private func flapBird() {
        guard state == .playing else { return }

        birdNode.physicsBody?.velocity = CGVector(dx: 0, dy: GameConfig.birdFlapVelocity)
        birdNode.zRotation = 0.35
    }

    private func spawnPipesIfNeeded(at currentTime: TimeInterval) {
        if nextPipeSpawnTime == nil {
            nextPipeSpawnTime = currentTime + GameConfig.pipeSpawnDelay
        }

        guard let nextPipeSpawnTime else { return }

        if currentTime >= nextPipeSpawnTime {
            spawnPipePair()
            self.nextPipeSpawnTime = nextPipeSpawnTime + GameConfig.pipeSpawnInterval
        }
    }

    private func spawnPipePair() {
        let playfieldTop = size.height
        let playfieldBottom = GameConfig.groundHeight
        let gapCenterY = CGFloat.random(in: GameConfig.pipeMinimumCenterY...GameConfig.pipeMaximumCenterY)
        let gapTop = gapCenterY + GameConfig.pipeGap * 0.5
        let gapBottom = gapCenterY - GameConfig.pipeGap * 0.5

        let topPipeHeight = max(80, playfieldTop - gapTop)
        let bottomPipeHeight = max(80, gapBottom - playfieldBottom)

        let pipePair = SKNode()
        pipePair.name = GameConfig.pipePairNodeName
        pipePair.zPosition = 30
        pipePair.position = CGPoint(x: size.width + GameConfig.pipeWidth, y: 0)
        addChild(pipePair)

        let topPipe = makePipe(height: topPipeHeight, imageName: GameConfig.Artwork.pipeTop)
        topPipe.position = CGPoint(x: 0, y: gapTop + topPipeHeight * 0.5)
        pipePair.addChild(topPipe)

        let bottomPipe = makePipe(height: bottomPipeHeight, imageName: GameConfig.Artwork.pipeBottom)
        bottomPipe.position = CGPoint(x: 0, y: playfieldBottom + bottomPipeHeight * 0.5)
        pipePair.addChild(bottomPipe)

        let scoreNode = SKNode()
        let obstacleID = "\(GameConfig.scoreNodePrefix)\(pipeSequence)"
        pipeSequence += 1
        scoreNode.name = obstacleID
        scoreNode.position = CGPoint(x: GameConfig.pipeWidth * 0.5, y: playfieldBottom + (playfieldTop - playfieldBottom) * 0.5)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 12, height: playfieldTop - playfieldBottom))
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = GameConfig.PhysicsCategory.score
        scoreNode.physicsBody?.contactTestBitMask = GameConfig.PhysicsCategory.bird
        scoreNode.physicsBody?.collisionBitMask = 0
        pipePair.addChild(scoreNode)

        let travelDistance = size.width + GameConfig.pipeWidth * 3
        let moveAction = SKAction.moveBy(x: -travelDistance, y: 0, duration: GameConfig.pipeTravelDuration)
        let cleanupAction = SKAction.removeFromParent()
        pipePair.run(.sequence([moveAction, cleanupAction]))
    }

    private func makePipe(height: CGFloat, imageName: String) -> SKNode {
        let pipeNode = SKNode()

        let bodyNode = SKSpriteNode(imageNamed: imageName)
        bodyNode.texture?.filteringMode = .nearest
        bodyNode.size = CGSize(width: GameConfig.pipeWidth, height: height)
        bodyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: GameConfig.pipeWidth - 10, height: height))
        bodyNode.physicsBody?.isDynamic = false
        bodyNode.physicsBody?.categoryBitMask = GameConfig.PhysicsCategory.world
        bodyNode.physicsBody?.contactTestBitMask = GameConfig.PhysicsCategory.bird
        bodyNode.physicsBody?.collisionBitMask = GameConfig.PhysicsCategory.bird
        pipeNode.addChild(bodyNode)

        return pipeNode
    }

    private func handleScore(contact: SKPhysicsContact) {
        guard state == .playing else { return }

        let scoreNode: SKNode?
        if contact.bodyA.categoryBitMask == GameConfig.PhysicsCategory.score {
            scoreNode = contact.bodyA.node
        } else {
            scoreNode = contact.bodyB.node
        }

        guard let scoreNode, let scoreNodeName = scoreNode.name else { return }
        guard scoreNodeName.hasPrefix(GameConfig.scoreNodePrefix) else { return }

        score += 1
        scoreNode.physicsBody?.categoryBitMask = 0
        scoreNode.removeFromParent()

        if UserDefaults.standard.object(forKey: GameConfig.StorageKey.isHapticsEnabled) as? Bool != false {
            scoreFeedback.impactOccurred()
            scoreFeedback.prepare()
        }
    }

    private func handleCollision() {
        guard state == .playing else { return }

        state = .gameOver(restartAvailableAt: currentSceneTime + GameConfig.restartDelay)
        nextPipeSpawnTime = nil

        birdNode.removeAction(forKey: "hover")
        birdNode.removeAction(forKey: "flap")
        birdNode.texture = birdHitTexture
        birdNode.physicsBody?.isDynamic = false
        birdNode.physicsBody?.affectedByGravity = false
        birdNode.physicsBody?.velocity = .zero
        birdNode.zRotation = -0.85

        enumerateChildNodes(withName: GameConfig.pipePairNodeName) { node, _ in
            node.removeAllActions()
        }

        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: GameConfig.StorageKey.highScore)
        }

        resultTitleLabel.text = "Crash"
        resultBodyLabel.text = "Score \(score)\nBest \(highScore)"
        resultPanel.isHidden = false

        if UserDefaults.standard.object(forKey: GameConfig.StorageKey.isHapticsEnabled) as? Bool != false {
            failFeedback.notificationOccurred(.warning)
            failFeedback.prepare()
        }
    }

    private func removeActivePipePairs() {
        children
            .filter { $0.name == GameConfig.pipePairNodeName }
            .forEach { $0.removeFromParent() }
    }

    private func runBirdFlapAnimation() {
        guard !birdFlapTextures.isEmpty else { return }

        let flapAction = SKAction.animate(with: birdFlapTextures, timePerFrame: 0.08, resize: false, restore: false)
        birdNode.run(.repeatForever(flapAction), withKey: "flap")
    }

    private func resetBirdForReadyState() {
        birdNode.position = GameConfig.birdStartPoint
        birdNode.zRotation = 0
        birdNode.removeAllActions()
        birdNode.texture = birdFlapTextures.first
        runBirdFlapAnimation()
        birdNode.physicsBody?.isDynamic = false
        birdNode.physicsBody?.affectedByGravity = false
        birdNode.physicsBody?.velocity = .zero
        birdShadowNode.position = CGPoint(x: GameConfig.birdStartPoint.x, y: GameConfig.groundHeight + 24)

        let hoverUp = SKAction.moveBy(x: 0, y: GameConfig.birdHoverDistance, duration: 0.7)
        hoverUp.timingMode = .easeInEaseOut
        let hoverDown = hoverUp.reversed()
        let hoverLoop = SKAction.repeatForever(.sequence([hoverUp, hoverDown]))
        birdNode.run(hoverLoop, withKey: "hover")
    }

    private func updateBirdRotation() {
        guard state == .playing else { return }
        guard let velocity = birdNode.physicsBody?.velocity else { return }

        if velocity.dy < GameConfig.birdMaxFallVelocity {
            birdNode.physicsBody?.velocity.dy = GameConfig.birdMaxFallVelocity
        }

        let normalizedLift = max(-1.0, min(1.0, velocity.dy / GameConfig.birdFlapVelocity))
        birdNode.zRotation = normalizedLift * 0.55
        birdShadowNode.position.x = birdNode.position.x
    }
}
