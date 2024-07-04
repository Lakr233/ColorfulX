//
//  AnimatedMulticolorGradientView+Speckle.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import Foundation
import SpringInterpolation
import ColorVector

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
