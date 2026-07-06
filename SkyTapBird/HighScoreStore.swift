//
//  HighScoreStore.swift
//  SkyTapBird
//

import Foundation

protocol HighScoreStoring {
    func loadHighScore() -> Int
    func saveHighScore(_ score: Int)
}

struct UserDefaultsHighScoreStore: HighScoreStoring {
    private let userDefaults: UserDefaults
    private let key: String

    init(
        userDefaults: UserDefaults = .standard,
        key: String = GameConfig.StorageKey.highScore
    ) {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadHighScore() -> Int {
        max(0, userDefaults.integer(forKey: key))
    }

    func saveHighScore(_ score: Int) {
        userDefaults.set(max(0, score), forKey: key)
    }
}
