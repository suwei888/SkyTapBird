//
//  GameSession.swift
//  SkyTapBird
//

import Foundation

struct GameSession {
    private(set) var state: GameState = .ready
    private(set) var score = 0
    private(set) var highScore: Int

    init(highScore: Int) {
        self.highScore = max(0, highScore)
    }

    @discardableResult
    mutating func start() -> Bool {
        guard state == .ready else { return false }
        state = .playing
        return true
    }

    @discardableResult
    mutating func scorePoint() -> Bool {
        guard state == .playing else { return false }
        score += 1
        return true
    }

    @discardableResult
    mutating func finish(at currentTime: TimeInterval, restartDelay: TimeInterval) -> Bool {
        guard state == .playing else { return false }

        state = .gameOver(restartAvailableAt: currentTime + restartDelay)

        guard score > highScore else { return false }
        highScore = score
        return true
    }

    func canRestart(at currentTime: TimeInterval) -> Bool {
        guard case let .gameOver(restartAvailableAt) = state else { return false }
        return currentTime >= restartAvailableAt
    }

    mutating func reset() {
        state = .ready
        score = 0
    }
}
