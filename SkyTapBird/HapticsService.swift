//
//  HapticsService.swift
//  SkyTapBird
//

import UIKit

protocol HapticsProviding {
    func prepare()
    func playScoreFeedback()
    func playFailureFeedback()
}

final class SystemHapticsService: HapticsProviding {
    private let userDefaults: UserDefaults
    private let scoreGenerator = UIImpactFeedbackGenerator(style: .light)
    private let failureGenerator = UINotificationFeedbackGenerator()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func prepare() {
        guard isEnabled else { return }
        scoreGenerator.prepare()
        failureGenerator.prepare()
    }

    func playScoreFeedback() {
        guard isEnabled else { return }
        scoreGenerator.impactOccurred()
        scoreGenerator.prepare()
    }

    func playFailureFeedback() {
        guard isEnabled else { return }
        failureGenerator.notificationOccurred(.warning)
        failureGenerator.prepare()
    }

    private var isEnabled: Bool {
        userDefaults.object(forKey: GameConfig.StorageKey.isHapticsEnabled) as? Bool != false
    }
}
