//
//  MulticolorGradientView+Lerpable.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import Foundation

extension MulticolorGradientView.Parameters.ColorStop.CoordinateVec2D: Lerpable {
    public func lerp(to newValue: Self, percent delta: Double) -> Self {
        .init(
            x: x.lerp(to: newValue.x, percent: delta),
            y: y.lerp(to: newValue.y, percent: delta),
        )
    }
}
