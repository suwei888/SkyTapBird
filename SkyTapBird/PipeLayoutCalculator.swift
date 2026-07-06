//
//  PipeLayoutCalculator.swift
//  SkyTapBird
//

import CoreGraphics

struct PipeLayout: Equatable {
    let gapCenterY: CGFloat
    let gap: CGFloat
    let topPipeHeight: CGFloat
    let bottomPipeHeight: CGFloat

    var gapTop: CGFloat {
        gapCenterY + gap * 0.5
    }

    var gapBottom: CGFloat {
        gapCenterY - gap * 0.5
    }
}

struct PipeLayoutCalculator {
    let requestedGap: CGFloat
    let minimumPipeHeight: CGFloat

    init(
        requestedGap: CGFloat = GameConfig.pipeGap,
        minimumPipeHeight: CGFloat = GameConfig.pipeMinimumHeight
    ) {
        self.requestedGap = requestedGap
        self.minimumPipeHeight = minimumPipeHeight
    }

    func makeLayout(
        playfield: ClosedRange<CGFloat>,
        randomUnit: CGFloat
    ) -> PipeLayout {
        let availableHeight = max(1, playfield.upperBound - playfield.lowerBound)
        let effectiveGap = min(requestedGap, availableHeight * 0.65)
        let remainingHeight = max(0, availableHeight - effectiveGap)
        let effectiveMinimumHeight = min(minimumPipeHeight, remainingHeight * 0.5)

        let minimumCenter = playfield.lowerBound + effectiveMinimumHeight + effectiveGap * 0.5
        let maximumCenter = playfield.upperBound - effectiveMinimumHeight - effectiveGap * 0.5
        let clampedUnit = min(1, max(0, randomUnit))
        let centerRange = max(0, maximumCenter - minimumCenter)
        let centerY = minimumCenter + centerRange * clampedUnit

        return PipeLayout(
            gapCenterY: centerY,
            gap: effectiveGap,
            topPipeHeight: max(
                effectiveMinimumHeight,
                playfield.upperBound - (centerY + effectiveGap * 0.5)
            ),
            bottomPipeHeight: max(
                effectiveMinimumHeight,
                (centerY - effectiveGap * 0.5) - playfield.lowerBound
            )
        )
    }
}
