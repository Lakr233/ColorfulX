//
//  AnimatedMulticolorGradientView+ColorElement.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import Foundation
import SpringInterpolation

public extension AnimatedMulticolorGradientView {
    struct ColorElement {
        public var enabled: Bool

        public var targetColor: RGBColor
        public var previousColor: RGBColor
        public var transitionProgress: Double
        public var position: SpringInterpolation2D

        public var currentColor: RGBColor {
            if transitionProgress.isZero {
                return previousColor
            }
            if transitionProgress + 0.01 >= 1 {
                return targetColor
            }
            return previousColor.lerp(to: targetColor, percent: transitionProgress)
        }
    }
}
