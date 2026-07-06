//
//  PipeSpawner.swift
//  SkyTapBird
//

import CoreGraphics
import Foundation

final class PipeSpawner {
    private let layoutCalculator: PipeLayoutCalculator
    private let randomUnit: () -> CGFloat

    private var nextSpawnTime: TimeInterval?
    private var sequence = 0

    init(
        layoutCalculator: PipeLayoutCalculator = PipeLayoutCalculator(),
        randomUnit: @escaping () -> CGFloat = { CGFloat.random(in: 0 ... 1) }
    ) {
        self.layoutCalculator = layoutCalculator
        self.randomUnit = randomUnit
    }

    func start() {
        nextSpawnTime = nil
    }

    func reset() {
        nextSpawnTime = nil
        sequence = 0
    }

    func resynchronize(at currentTime: TimeInterval, isPlaying: Bool) {
        nextSpawnTime = isPlaying
            ? currentTime + GameConfig.pipeSpawnInterval
            : nil
    }

    func makePipePairIfNeeded(
        at currentTime: TimeInterval,
        sceneSize: CGSize,
        groundHeight: CGFloat
    ) -> PipePairNode? {
        if nextSpawnTime == nil {
            nextSpawnTime = currentTime + GameConfig.pipeSpawnDelay
            return nil
        }

        guard let nextSpawnTime, currentTime >= nextSpawnTime else {
            return nil
        }

        self.nextSpawnTime = currentTime + GameConfig.pipeSpawnInterval

        let playfieldTop = max(groundHeight + 1, sceneSize.height)
        let playfield = groundHeight ... playfieldTop
        let layout = layoutCalculator.makeLayout(
            playfield: playfield,
            randomUnit: randomUnit()
        )

        defer { sequence += 1 }

        return PipePairNode(
            layout: layout,
            playfield: playfield,
            sequence: sequence,
            sceneWidth: sceneSize.width
        )
    }
}
