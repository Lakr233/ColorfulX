//
//  MulticolorGradientView+Parameters.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import CoreGraphics
import Foundation

public extension MulticolorGradientView {
    struct Parameters: Equatable {
        public var points: [ColorStop]
        public var bias: Float
        public var power: Float
        public var noise: Float

        public init(
            points: [ColorStop] = [],
            bias: Float = 0.01,
            power: Float = 4,
            noise: Float = 0
        ) {
            self.points = points
            self.bias = bias
            self.power = power
            self.noise = noise
        }
    }
}

public extension MulticolorGradientView.Parameters {
    struct ColorStop: Equatable {
        public let color: RGBColor
        public let position: CoordinateVec2D

        public init(color: RGBColor, position: CoordinateVec2D) {
            self.color = color
            self.position = position
        }
    }
}

public extension MulticolorGradientView.Parameters.ColorStop {
    struct CoordinateVec2D: Equatable {
        public let x: Double
        public let y: Double
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }
}
