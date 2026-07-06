//
//  GameScene.swift
//  SkyTapBird
//

import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let highScoreStore: HighScoreStoring
    private let haptics: HapticsProviding
    private let pipeSpawner: PipeSpawner

    private var session: GameSession
    private var currentSceneTime: TimeInterval = 0
    private var hasCompletedInitialSetup = false
    private var needsTimeResynchronization = false
    private var safeAreaTop: CGFloat = 0

    private let backgroundNode = SKSpriteNode(imageNamed: GameConfig.Artwork.backgroundDay)
    private let sunNode = SKSpriteNode(imageNamed: GameConfig.Artwork.sun)
    private let smallCloudNode = SKSpriteNode(imageNamed: GameConfig.Artwork.cloudSmall)
    private let largeCloudNode = SKSpriteNode(imageNamed: GameConfig.Artwork.cloudLarge)
    private let groundNode = SKSpriteNode(imageNamed: GameConfig.Artwork.groundStrip)
    private let birdNode = BirdNode()
    private let birdShadowNode = SKShapeNode(
        ellipseOf: CGSize(width: 52, height: 14)
    )
    private let hudNode = GameHUDNode()
    private let gameOverPanelNode = GameOverPanelNode()

    init(
        size: CGSize,
        highScoreStore: HighScoreStoring = UserDefaultsHighScoreStore(),
        haptics: HapticsProviding = SystemHapticsService(),
        randomUnit: @escaping () -> CGFloat = { CGFloat.random(in: 0 ... 1) }
    ) {
        self.highScoreStore = highScoreStore
        self.haptics = haptics
        pipeSpawner = PipeSpawner(randomUnit: randomUnit)
        session = GameSession(highScore: highScoreStore.loadHighScore())

        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        let store = UserDefaultsHighScoreStore()
        highScoreStore = store
        haptics = SystemHapticsService()
        pipeSpawner = PipeSpawner()
        session = GameSession(highScore: store.loadHighScore())

        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        guard !hasCompletedInitialSetup else { return }
        hasCompletedInitialSetup = true

        backgroundColor = SKColor(
            red: 0.56,
            green: 0.83,
            blue: 0.98,
            alpha: 1
        )
        physicsWorld.gravity = CGVector(dx: 0, dy: -18)
        physicsWorld.contactDelegate = self

        haptics.prepare()
        configureBackdrop()
        configureGround()
        configureBird()
        addChild(hudNode)
        addChild(gameOverPanelNode)

        layoutScene()
        enterReadyState()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutScene()

        guard oldSize != .zero, session.state == .playing else { return }
        enterReadyState()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !touches.isEmpty else { return }

        switch session.state {
        case .ready:
            startRun()
            birdNode.flap()

        case .playing:
            birdNode.flap()

        case .gameOver:
            guard session.canRestart(at: currentSceneTime) else { return }
            enterReadyState()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if needsTimeResynchronization {
            pipeSpawner.resynchronize(
                at: currentTime,
                isPlaying: session.state == .playing
            )
            needsTimeResynchronization = false
        }

        switch session.state {
        case .ready:
            break

        case .playing:
            birdNode.updateRotation()
            birdShadowNode.position.x = birdNode.position.x

            if let pipePair = pipeSpawner.makePipePairIfNeeded(
                at: currentTime,
                sceneSize: size,
                groundHeight: GameConfig.groundHeight
            ) {
                addChild(pipePair)
            }

        case .gameOver:
            gameOverPanelNode.updateRestartAvailability(
                session.canRestart(at: currentTime)
            )
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstCategory = contact.bodyA.categoryBitMask
        let secondCategory = contact.bodyB.categoryBitMask
        let pairMask = firstCategory | secondCategory

        guard pairMask & GameConfig.PhysicsCategory.bird != 0 else {
            return
        }

        if pairMask & GameConfig.PhysicsCategory.score != 0 {
            handleScore(contact: contact)
        } else {
            handleCollision()
        }
    }

    func updateSafeArea(top: CGFloat) {
        safeAreaTop = max(0, top)
        layoutScene()
    }

    func setApplicationPaused(_ paused: Bool) {
        if !paused {
            needsTimeResynchronization = true
        }
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
        addChild(groundNode)
        rebuildGroundPhysicsBody()
    }

    private func configureBird() {
        addChild(birdNode)

        birdShadowNode.fillColor = SKColor(white: 0, alpha: 0.12)
        birdShadowNode.strokeColor = .clear
        birdShadowNode.zPosition = 10
        addChild(birdShadowNode)
    }

    private func layoutScene() {
        guard size.width > 0, size.height > 0 else { return }

        resizeSprite(backgroundNode, toFill: size)
        backgroundNode.position = CGPoint(
            x: size.width * 0.5,
            y: size.height * 0.5
        )

        sunNode.size = CGSize(width: 58, height: 58)
        sunNode.position = CGPoint(
            x: size.width * 0.77,
            y: size.height * 0.82
        )

        smallCloudNode.size = CGSize(width: 80, height: 40)
        smallCloudNode.position = CGPoint(
            x: size.width * 0.24,
            y: size.height * 0.82
        )

        largeCloudNode.size = CGSize(width: 108, height: 49)
        largeCloudNode.position = CGPoint(
            x: size.width * 0.66,
            y: size.height * 0.68
        )

        groundNode.size = CGSize(
            width: size.width + 80,
            height: GameConfig.groundHeight
        )
        groundNode.position = CGPoint(
            x: size.width * 0.5,
            y: GameConfig.groundHeight * 0.5
        )
        rebuildGroundPhysicsBody()

        let startPoint = birdStartPoint
        if session.state == .ready {
            birdNode.reset(at: startPoint)
        }

        birdShadowNode.position = CGPoint(
            x: birdNode.position.x,
            y: GameConfig.groundHeight + 24
        )

        hudNode.layout(
            in: size,
            safeAreaTop: safeAreaTop,
            groundHeight: GameConfig.groundHeight
        )
        gameOverPanelNode.layout(in: size)
    }

    private var birdStartPoint: CGPoint {
        let preferredY = size.height * GameConfig.birdStartYFraction
        let minimumY = GameConfig.groundHeight + 120
        let maximumY = max(minimumY, size.height - safeAreaTop - 180)

        return CGPoint(
            x: max(96, size.width * GameConfig.birdStartXFraction),
            y: min(maximumY, max(minimumY, preferredY))
        )
    }

    private func enterReadyState() {
        session.reset()
        pipeSpawner.reset()
        removeActivePipePairs()

        birdNode.reset(at: birdStartPoint)
        birdShadowNode.position = CGPoint(
            x: birdStartPoint.x,
            y: GameConfig.groundHeight + 24
        )

        hudNode.update(
            score: session.score,
            highScore: session.highScore
        )
        hudNode.showReady()
        gameOverPanelNode.hide()
    }

    private func startRun() {
        guard session.start() else { return }

        pipeSpawner.start()
        hudNode.showPlaying()
        gameOverPanelNode.hide()
        birdNode.startPlaying()
    }

    private func handleScore(contact: SKPhysicsContact) {
        guard session.state == .playing else { return }

        let scoreBody: SKPhysicsBody?
        if contact.bodyA.categoryBitMask == GameConfig.PhysicsCategory.score {
            scoreBody = contact.bodyA
        } else if contact.bodyB.categoryBitMask == GameConfig.PhysicsCategory.score {
            scoreBody = contact.bodyB
        } else {
            scoreBody = nil
        }

        guard
            let scoreBody,
            let scoreNode = scoreBody.node,
            scoreNode.name?.hasPrefix(GameConfig.NodeName.scorePrefix) == true
        else {
            return
        }

        scoreBody.categoryBitMask = 0
        scoreNode.removeFromParent()

        guard session.scorePoint() else { return }

        hudNode.update(
            score: session.score,
            highScore: session.highScore
        )
        haptics.playScoreFeedback()
    }

    private func handleCollision() {
        let hasNewHighScore = session.finish(
            at: currentSceneTime,
            restartDelay: GameConfig.restartDelay
        )
        guard case .gameOver = session.state else { return }

        pipeSpawner.reset()
        birdNode.crash()

        enumerateChildNodes(
            withName: GameConfig.NodeName.pipePair
        ) { node, _ in
            (node as? PipePairNode)?.freeze()
        }

        if hasNewHighScore {
            highScoreStore.saveHighScore(session.highScore)
        }

        hudNode.update(
            score: session.score,
            highScore: session.highScore
        )
        gameOverPanelNode.show(
            score: session.score,
            highScore: session.highScore
        )
        haptics.playFailureFeedback()
    }

    private func removeActivePipePairs() {
        children
            .filter { $0.name == GameConfig.NodeName.pipePair }
            .forEach { $0.removeFromParent() }
    }

    private func rebuildGroundPhysicsBody() {
        guard groundNode.size.width > 0, groundNode.size.height > 0 else {
            return
        }

        let body = SKPhysicsBody(rectangleOf: groundNode.size)
        body.isDynamic = false
        body.categoryBitMask = GameConfig.PhysicsCategory.world
        body.contactTestBitMask = GameConfig.PhysicsCategory.bird
        body.collisionBitMask = GameConfig.PhysicsCategory.bird
        groundNode.physicsBody = body
    }

    private func resizeSprite(
        _ sprite: SKSpriteNode,
        toFill targetSize: CGSize
    ) {
        guard
            let textureSize = sprite.texture?.size(),
            textureSize.width > 0,
            textureSize.height > 0
        else {
            sprite.size = targetSize
            return
        }

        let scale = max(
            targetSize.width / textureSize.width,
            targetSize.height / textureSize.height
        )
        sprite.size = CGSize(
            width: textureSize.width * scale,
            height: textureSize.height * scale
        )
    }
}
