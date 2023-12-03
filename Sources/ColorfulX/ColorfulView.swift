//
//  ColorfulView.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import SwiftUI

public struct ColorfulView: View {
    private let fps: Int
    @Binding var colors: [Color]
    @Binding var speedFactor: Double
    @Binding var colorTransitionDuration: TimeInterval

    public init(
        fps: Int = 60,
        colors: Binding<[Color]>,
        speedFactor: Binding<Double> = .constant(1.0),
        colorTransitionDuration: Binding<TimeInterval> = .constant(5)
    ) {
        self.fps = fps

        _colors = colors
        _speedFactor = speedFactor
        _colorTransitionDuration = colorTransitionDuration
    }

    public var body: some View {
        AnimatedMulticolorGradientViewRepresentable(
            colors: .init(get: {
                colors.map { RGBColor(CoreColor($0)) }
            }, set: { _ in assertionFailure() }),
            speedFactor: $speedFactor,
            colorTransitionDuration: $colorTransitionDuration,
            fps: fps
        )
    }
}
