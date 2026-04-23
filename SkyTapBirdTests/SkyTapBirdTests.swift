//
//  SkyTapBirdTests.swift
//  SkyTapBirdTests
//
//  Created by SkyTapBird contributors.
//

import XCTest
import UIKit
import SpriteKit
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
                UIImage(named: artworkName, in: Bundle(for: GameScene.self), compatibleWith: nil),
                "Missing artwork asset: \(artworkName)"
            )
        }
    }
}
