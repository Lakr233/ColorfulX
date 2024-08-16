//
//  AnimatedMulticolorGradientView+Speckle.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
import Foundation
import SpringInterpolation

public extension AnimatedMulticolorGradientView {
    struct Speckle {
        public var enabled: Bool

        public var targetColor: ColorVector
        public var previousColor: ColorVector
        public var transitionProgress: SpringInterpolation
        public var position: SpringInterpolation2D

        public init(
            enabled: Bool = false,
            targetColor: ColorVector = .init(space: .rgb),
            previousColor: ColorVector = .init(space: .rgb),
            transitionProgress: Double = 1,
            position: SpringInterpolation2D = .init()
        ) {
            self.enabled = enabled
            self.targetColor = targetColor
            self.previousColor = previousColor
            self.transitionProgress = .init(
                config: .init(angularFrequency: 0.5, dampingRatio: 1.0),
                context: .init(
                    currentPos: transitionProgress,
                    currentVel: 0,
                    targetPos: transitionProgress
                )
            )
            self.position = position
        }
    }
}

extension AnimatedMulticolorGradientView.Speckle {
    var colorVector: ColorVector {
        let progress = transitionProgress.context.currentPos
        return previousColor.lerp(to: targetColor, percent: progress)
    }
}

public extension AnimatedMulticolorGradientView {
    func setColors(_ colors: [ColorVector], interpolationEnabled: Bool = true, repeatToFillColorSlots: Bool = true) {
        var colors = colors
        if colors.isEmpty { colors.append(.init(v: .zero, space: .rgb)) }
        colors = colors.map { $0.color(in: .lab) }

        let endingIndex = repeatToFillColorSlots ? Uniforms.COLOR_SLOT : min(colors.count, Uniforms.COLOR_SLOT)
        guard endingIndex > 0 else { return }

        alteringSpeckles { speckles in
            for idx in 0 ..< endingIndex {
                var read = speckles[idx]
                let color: ColorVector = colors[idx % colors.count]
                guard read.targetColor != color else { continue }
                let interpolationEnabled = interpolationEnabled && read.enabled
                read.enabled = true
                read.targetColor = color
                read.previousColor = interpolationEnabled ? read.colorVector : color
                read.transitionProgress.setCurrent(interpolationEnabled ? 0 : 1, 0)
                speckles[idx] = read
            }
        }
    }
}
