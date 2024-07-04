//
//  MulticolorGradientView+Parameters.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
import CoreGraphics
import Foundation

public extension MulticolorGradientView {
    struct Parameters: Equatable {
        public var points: [ColorStop]
        public var bias: Double
        public var power: Double
        public var noise: Double

        public init(
            points: [ColorStop] = [],
            bias: Double = 0.01,
            power: Double = 4,
            noise: Double = 0
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
        public let color: ColorVector
        public let position: CoordinateVec2D

        public init(color: ColorVector, position: CoordinateVec2D) {
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
