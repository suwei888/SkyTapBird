//
//  GameConfig.swift
//  SkyTapBird
//

import CoreGraphics
import Foundation

enum GameConfig {
    static let fallbackSceneSize = CGSize(width: 390, height: 844)

    static let groundHeight: CGFloat = 118
    static let hudTopPadding: CGFloat = 38
    static let sideInset: CGFloat = 26

    static let birdSize = CGSize(width: 34, height: 26)
    static let birdStartXFraction: CGFloat = 0.31
    static let birdStartYFraction: CGFloat = 0.59
    static let birdFlapVelocity: CGFloat = 370
    static let birdMaxFallVelocity: CGFloat = -520
    static let birdHoverDistance: CGFloat = 9

    static let pipeWidth: CGFloat = 64
    static let pipeGap: CGFloat = 172
    static let pipeMinimumHeight: CGFloat = 80
    static let pipeSpawnDelay: TimeInterval = 1.15
    static let pipeSpawnInterval: TimeInterval = 1.65
    static let pipeTravelDuration: TimeInterval = 4.2

    static let restartDelay: TimeInterval = 0.45

    enum NodeName {
        static let pipePair = "pipePair"
        static let scorePrefix = "score-"
    }

    enum ActionKey {
        static let birdHover = "bird.hover"
        static let birdFlap = "bird.flap"
    }

    enum PhysicsCategory {
        static let bird: UInt32 = 1 << 0
        static let world: UInt32 = 1 << 1
        static let score: UInt32 = 1 << 2
    }

    enum StorageKey {
        static let highScore = "game.highScore"
        static let isHapticsEnabled = "settings.isHapticsEnabled"
    }

    enum Artwork {
        static let backgroundDay = "sprites_world_background_day"
        static let groundStrip = "sprites_world_ground_strip"
        static let cloudSmall = "sprites_world_cloud_01"
        static let cloudLarge = "sprites_world_cloud_02"
        static let sun = "sprites_world_sun"
        static let pipeTop = "sprites_obstacles_pipe_top"
        static let pipeBottom = "sprites_obstacles_pipe_bottom"
        static let titleLogo = "ui_icons_fly_bird_logo"
        static let gameOverPanel = "ui_panels_game_over_panel"
        static let restartButton = "ui_buttons_restart_button"
        static let birdHit = "sprites_bird_yellow_bird_yellow_hit"
        static let birdFlapFrames = [
            "sprites_bird_yellow_bird_yellow_flap_01",
            "sprites_bird_yellow_bird_yellow_flap_02",
            "sprites_bird_yellow_bird_yellow_flap_03",
            "sprites_bird_yellow_bird_yellow_flap_04",
        ]

        static let requiredImageNames = [
            backgroundDay,
            groundStrip,
            cloudSmall,
            cloudLarge,
            sun,
            pipeTop,
            pipeBottom,
            titleLogo,
            gameOverPanel,
            restartButton,
            birdHit,
        ] + birdFlapFrames
    }
}
