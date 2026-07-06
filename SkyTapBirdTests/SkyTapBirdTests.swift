//
//  SkyTapBirdTests.swift
//  SkyTapBirdTests
//

import SpriteKit
import UIKit
import XCTest
@testable import SkyTapBird

final class SkyTapBirdTests: XCTestCase {
    func testGameViewControllerBuildsSpriteKitViewProgrammatically() {
        let viewController = GameViewController()

        viewController.loadViewIfNeeded()

        XCTAssertTrue(viewController.view is SKView)
    }

    func testArtworkNamesAreUniqueAndLoadable() {
        let artworkNames = GameConfig.Artwork.requiredImageNames

        XCTAssertEqual(Set(artworkNames).count, artworkNames.count)

        for artworkName in artworkNames {
            XCTAssertFalse(artworkName.isEmpty)
            XCTAssertNotNil(
                UIImage(
                    named: artworkName,
                    in: Bundle(for: GameScene.self),
                    compatibleWith: nil
                ),
                "Missing artwork asset: \(artworkName)"
            )
        }
    }

    func testGameSessionFollowsExpectedStateFlow() {
        var session = GameSession(highScore: 2)

        XCTAssertEqual(session.state, .ready)
        XCTAssertTrue(session.start())
        XCTAssertEqual(session.state, .playing)

        XCTAssertTrue(session.scorePoint())
        XCTAssertTrue(session.scorePoint())
        XCTAssertTrue(session.scorePoint())
        XCTAssertEqual(session.score, 3)

        XCTAssertTrue(session.finish(at: 10, restartDelay: 0.5))
        XCTAssertEqual(session.highScore, 3)
        XCTAssertFalse(session.canRestart(at: 10.49))
        XCTAssertTrue(session.canRestart(at: 10.5))

        session.reset()
        XCTAssertEqual(session.state, .ready)
        XCTAssertEqual(session.score, 0)
        XCTAssertEqual(session.highScore, 3)
    }

    func testGameSessionIgnoresInvalidTransitions() {
        var session = GameSession(highScore: 0)

        XCTAssertFalse(session.scorePoint())
        XCTAssertFalse(session.finish(at: 0, restartDelay: 1))
        XCTAssertTrue(session.start())
        XCTAssertFalse(session.start())
    }

    func testPipeLayoutStaysInsidePlayfieldForAnyRandomValue() {
        let calculator = PipeLayoutCalculator(
            requestedGap: 172,
            minimumPipeHeight: 80
        )
        let playfield: ClosedRange<CGFloat> = 118 ... 844

        for randomUnit in [-1.0, 0.0, 0.5, 1.0, 2.0] {
            let layout = calculator.makeLayout(
                playfield: playfield,
                randomUnit: randomUnit
            )

            XCTAssertGreaterThanOrEqual(layout.gapBottom, playfield.lowerBound)
            XCTAssertLessThanOrEqual(layout.gapTop, playfield.upperBound)
            XCTAssertGreaterThanOrEqual(layout.topPipeHeight, 80)
            XCTAssertGreaterThanOrEqual(layout.bottomPipeHeight, 80)
        }
    }

    func testUserDefaultsHighScoreStoreUsesIsolatedSuite() {
        let suiteName = "SkyTapBirdTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = UserDefaultsHighScoreStore(
            userDefaults: defaults,
            key: "test.highScore"
        )

        XCTAssertEqual(store.loadHighScore(), 0)

        store.saveHighScore(12)

        XCTAssertEqual(store.loadHighScore(), 12)
    }
}
