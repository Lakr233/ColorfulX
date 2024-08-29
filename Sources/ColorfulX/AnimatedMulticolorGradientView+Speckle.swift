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

        public var targetColor: ColorVector {
            didSet { assert(targetColor.space == .lab) }
        }

        public var previousColor: ColorVector {
            didSet { assert(targetColor.space == .lab) }
        }

        public var transitionProgress: SpringInterpolation
        public var position: SpringInterpolation2D

        public var isTransitionCompleted: Bool {
            transitionProgress.context.currentPos >= 1
        }

        public var color: ColorVector {
            let progress = transitionProgress.context.currentPos
            return previousColor.lerp(to: targetColor, percent: progress)
        }

        public init(
            enabled: Bool = false,
            targetColor: ColorVector = .init(space: .lab),
            previousColor: ColorVector = .init(space: .lab),
            transitionProgress: Double = 1,
            position: SpringInterpolation2D = .init()
        ) {
            assert(targetColor.space == .lab)
            assert(previousColor.space == .lab)

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

public extension AnimatedMulticolorGradientView {
    
    func setColors(_ preset: ColorfulPreset, animated: Bool = true, repeats: Bool = true) {
        setColors(preset.colors.map { ColorVector(ColorElement($0)) },
                  animated: animated,
                  repeats: repeats)
    }
    
    func setColors(_ colors: [ColorVector], animated: Bool = true, repeats: Bool = true) {
        var colors = colors
        if colors.isEmpty { colors.append(.init(v: .zero, space: .lab)) }
        colors = colors.map { $0.color(in: .lab) }

        let endingIndex = repeats
            ? Uniforms.COLOR_SLOT
            : min(colors.count, Uniforms.COLOR_SLOT)

        alteringSpeckleByIteratingValues { speckle, idx in
            guard idx < endingIndex else {
                speckle.enabled = false
                return
            }

            speckle.enabled = true

            let newColor: ColorVector = colors[idx % colors.count]
            guard speckle.targetColor != newColor else { return }

            if animated {
                speckle.previousColor = speckle.color
                speckle.targetColor = newColor
                speckle.transitionProgress.setCurrent(0)
            } else {
                speckle.previousColor = newColor
                speckle.targetColor = newColor
                speckle.transitionProgress.setCurrent(1)
            }
        }
    }
}
