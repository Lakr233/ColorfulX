//
//  MulticolorGradientView+Parameters.swift
//
//
//  Created by QAQ on 2023/12/3.
//

@preconcurrency import ColorVector
import CoreGraphics
import Foundation

extension MulticolorGradientView {
  public struct Parameters: Equatable, Sendable {
    public var points: [ColorStop]
    public var bias: Double
    public var power: Double
    public var noise: Double

    public init(
      points: [ColorStop] = [],
      bias: Double = 0.01,
      power: Double = 4,
      noise: Double = 0,
    ) {
      self.points = points
      self.bias = bias
      self.power = power
      self.noise = noise
    }
  }
}

extension MulticolorGradientView.Parameters {
  public struct ColorStop: Equatable, Sendable {
    public let color: ColorVector
    public let position: CoordinateVec2D

    public init(color: ColorVector, position: CoordinateVec2D) {
      self.color = color
      self.position = position
    }
  }
}

extension MulticolorGradientView.Parameters.ColorStop {
  public struct CoordinateVec2D: Equatable, Sendable {
    public let x: Double
    public let y: Double
    public init(x: Double, y: Double) {
      self.x = x
      self.y = y
    }
  }
}
