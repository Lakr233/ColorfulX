//
//  MulticolorGradientView+Lerpable.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import Foundation

extension MulticolorGradientView.Parameters: Lerpable {
    func lerp(to newValue: Self, percent delta: Double) -> Self {
        assert(delta >= 0 && delta <= 1)

        var fromPoints = points
        let toPoints = newValue.points
        while fromPoints.count > toPoints.count, !fromPoints.isEmpty {
            fromPoints.removeLast()
        }
        while fromPoints.count < toPoints.count {
            fromPoints.append(.init(color: .init(r: 0, g: 0, b: 0), position: .init(x: 0, y: 0)))
        }
        assert(fromPoints.count == toPoints.count)
        return .init(
            points: fromPoints.enumerated().map { idx, colorStop -> ColorStop in
                colorStop.lerp(to: toPoints[idx], percent: delta)
            },
            bias: bias.lerp(to: newValue.bias, percent: delta),
            power: power.lerp(to: newValue.power, percent: delta),
            noise: noise.lerp(to: newValue.noise, percent: delta)
        )
    }
}

extension MulticolorGradientView.Parameters.ColorStop.CoordinateVec2D: Lerpable {
    public func lerp(to newValue: Self, percent delta: Double) -> Self {
        assert(delta >= 0 && delta <= 1)

        return .init(
            x: x.lerp(to: newValue.x, percent: delta),
            y: y.lerp(to: newValue.y, percent: delta)
        )
    }
}

extension MulticolorGradientView.Parameters.ColorStop: Lerpable {
    func lerp(to newValue: Self, percent delta: Double) -> Self {
        assert(delta >= 0 && delta <= 1)

        return .init(
            color: color.lerp(to: newValue.color, percent: delta),
            position: position.lerp(to: newValue.position, percent: delta)
        )
    }
}
