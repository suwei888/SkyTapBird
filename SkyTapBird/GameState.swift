//
//  GameState.swift
//  SkyTapBird
//

import Foundation

enum GameState: Equatable {
    case ready
    case playing
    case gameOver(restartAvailableAt: TimeInterval)
}
