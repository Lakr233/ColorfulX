//
//  AnimatedMulticolorGradientView+Speckle.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import Foundation
import SpringInterpolation

public extension AnimatedMulticolorGradientView {
    struct Speckle {
        public var enabled: Bool

        public var targetColor: RGBColor
        public var previousColor: RGBColor
        public var transitionProgress: Double
        public var position: SpringInterpolation2D

        public init(
            enabled: Bool = false,
            targetColor: RGBColor = .init(r: 0.5, g: 0.5, b: 0.5),
            previousColor: RGBColor = .init(r: 0.5, g: 0.5, b: 0.5),
            transitionProgress: Double = 1,
            position: SpringInterpolation2D = .init()
        ) {
            self.enabled = enabled
            self.targetColor = targetColor
            self.previousColor = previousColor
            self.transitionProgress = transitionProgress
            self.position = position
        }
    }
}
